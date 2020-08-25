variable "vcconfig_datacenter" {
  default = "tf-dc"
}

variable "vcconfig_compute_cluster_name" {
  description = "Set the name for the new compute cluster"
  default     = "tf-compute-cluster"
}

variable "vcconfig_resourcepool" {
  description = "Resource pool name"
}

variable "vcconfig_dvs" {
  description = "Distributed virtual switch name"
}