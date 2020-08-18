provider "vsphere" {
  user           = var.vcconfig_vcssousername
  password       = var.vcconfig_vcssopassword
  vsphere_server = var.vcconfig_vcip

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
  ha_enabled           = true
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