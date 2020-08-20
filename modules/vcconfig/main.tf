provider "vsphere" {
  user           = data.terraform_remote_state.vcbuild.outputs.vcenter_username
  password       = data.terraform_remote_state.vcbuild.outputs.vcenter_password
  vsphere_server = data.terraform_remote_state.vcbuild.outputs.vcenter_ip_address

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_datacenter" "dc" {
  name = var.vcconfig_datacenter
}

data "vsphere_datacenter" "dc" {
  name       = var.vcconfig_datacenter
  depends_on = [vsphere_datacenter.dc]
}

resource "vsphere_compute_cluster" "compute_cluster" {
  name                 = var.vcconfig_compute_cluster_name
  datacenter_id        = data.vsphere_datacenter.dc.id
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  ha_enabled           = false
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vcconfig_compute_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_compute_cluster.compute_cluster]
}

resource "vsphere_resource_pool" "resource_pool" {
  name                    = var.vcconfig_resourcepool
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

# resource "vsphere_compute_cluster" "management_cluster" {
#   name            = "Management"
#   datacenter_id   = data.vsphere_datacenter.dc.id
#   drs_enabled          = true
#   drs_automation_level = "fullyAutomated"
#   ha_enabled = true
# }

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

resource "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vcconfig_dvs
  datacenter_id = data.vsphere_datacenter.dc.id

  uplinks         = ["uplink1", "uplink2", "uplink3", "uplink4"]
  active_uplinks  = ["uplink1", "uplink2"]
  standby_uplinks = ["uplink3", "uplink4"]
}
 data "vsphere_host_thumbprint" "thumbprint" {
   count = length(data.terraform_remote_state.hytrust_env_1_dev.outputs.ESXi_hostnames)
   address = element(data.terraform_remote_state.hytrust_env_1_dev.outputs.ESXi_hostnames, count.index)
   insecure = true
 }

resource "vsphere_host" "esxi" {
  depends_on = [data.vsphere_host_thumbprint.thumbprint]
  count = length(data.terraform_remote_state.hytrust_env_1_dev.outputs.ESXi_IP_addresses)
  hostname = element(data.terraform_remote_state.hytrust_env_1_dev.outputs.ESXi_IP_addresses, count.index)
  username = "root"
  password = data.terraform_remote_state.hytrust_env_1_dev.outputs.ESXi_root_password
  thumbprint = element(data.vsphere_host_thumbprint.thumbprint[*].id, count.index)
  #license  = "00000-00000-00000-00000i-00000"
  cluster  = data.vsphere_compute_cluster.compute_cluster.id
}