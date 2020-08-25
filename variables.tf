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