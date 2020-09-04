################################################################################
################################################################################
################################################################################
###                                                                          ###
### Name: terraform-vsphere-vcsa_config                                      ###
### Description: [Terraform] Module to configure VMware VCSA, join nested    ###
###   ESXi hosts to cluster                                                  ###
### Last Modified: fparry(2020-09-04T11:12:56-04:00)                         ###
### License: MIT (See LICENSE.txt in the root of this repository for more    ###
###   information.)                                                          ###
###                                                                          ###
################################################################################
################################################################################
################################################################################

provider "vsphere" {
  user           = data.terraform_remote_state.vmware_tfc_env1.outputs.vcenter_username
  password       = data.terraform_remote_state.vmware_tfc_env1.outputs.vcenter_password
  vsphere_server = data.terraform_remote_state.vmware_tfc_env1.outputs.vcenter_ip_address

  # If you have a self-signed cert
  allow_unverified_ssl = true
  version = "1.23.0"
}

# Create your Datacenter in vCenter
resource "vsphere_datacenter" "dc" {
  name = var.vcconfig_datacenter
}

# Retrieve Datacenter ID
data "vsphere_datacenter" "dc" {
  depends_on = [vsphere_datacenter.dc]
  name       = var.vcconfig_datacenter
}

# Data lookup for nested ESXi hosts- required to add them into vCenter
data "vsphere_host_thumbprint" "thumbprint" {
  count    = length(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_IP_addresses)
  address  = element(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_IP_addresses, count.index)
  insecure = true
}

# Create the nested hosts as standalone hosts in vCenter 
resource "vsphere_host" "esxi" {
  depends_on = [data.vsphere_host_thumbprint.thumbprint]
  count      = length(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_IP_addresses)
  hostname   = element(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_IP_addresses, count.index)
  username   = "root"
  password   = data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_root_password
  thumbprint = element(data.vsphere_host_thumbprint.thumbprint[*].id, count.index)
  datacenter = data.vsphere_datacenter.dc.id
  cluster_managed = true
}

# Data lookup on each nested host to retrieve the host_id
data "vsphere_host" "esxi" {
  depends_on = [vsphere_host.esxi]
  count         = length(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_IP_addresses)
  name          = element(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_IP_addresses, count.index)
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create/configure the vCenter host cluster and join the nested hosts to the cluster
resource "vsphere_compute_cluster" "compute_cluster" {
  depends_on           = [data.vsphere_host.esxi]
  name                 = var.vcconfig_compute_cluster_name
  datacenter_id        = data.vsphere_datacenter.dc.id
  host_system_ids      = [
    for host in range(length(data.terraform_remote_state.vmware_tfc_env1.outputs.ESXi_hostnames)) :
    data.vsphere_host.esxi[host].id]
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  ha_enabled           = false
}

# Data lookup on the host cluster to retrieve the cluster resource pool iD
data "vsphere_compute_cluster" "compute_cluster" {
  name          = vsphere_compute_cluster.compute_cluster.name
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_compute_cluster.compute_cluster]
}

# Create a new resource pool
resource "vsphere_resource_pool" "resource_pool" {
  name                    = var.vcconfig_resourcepool
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

# Create an additional cluster, if needed
# resource "vsphere_compute_cluster" "management_cluster" {
#   name            = "Management"
#   datacenter_id   = data.vsphere_datacenter.dc.id
#   drs_enabled          = true
#   drs_automation_level = "fullyAutomated"
#   ha_enabled = true
# }

# Create folders
resource "vsphere_folder" "infrafolder" {
  path          = "Infrastructure"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "templatesfolder" {
  path          = "Templates"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create a distributed virtual switch
resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vcconfig_dvs
  datacenter_id = data.vsphere_datacenter.dc.id

  uplinks         = ["uplink1", "uplink2", "uplink3", "uplink4"]
  active_uplinks  = ["uplink1", "uplink2"]
  standby_uplinks = ["uplink3", "uplink4"]
}