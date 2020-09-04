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

variable "vcconfig_datacenter" {
  default = "tf-dc"
}

variable "vcconfig_compute_cluster_name" {
  description = "Set the name for the new compute cluster"
  default     = "tf-compute-cluster"
}

variable "network_interfaces" {
  default = [
    "vmnic0",
    "vmnic1",
    "vmnic2",
    "vmnic3",
  ]
}

variable "vcconfig_resourcepool" {
  description = "Resource pool name"
}

variable "vcconfig_dvs" {
  description = "Distributed virtual switch name"
}

variable "vcconfig_tfc_org" {
  description = "Terraform Cloud organization name"
}

variable "vcconfig_tfc_workspace" {
  description = "Terraform Cloud workspace name"
}