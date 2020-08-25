module "vcconfig" {
  source                        = "./modules/vcconfig"
  vcconfig_compute_cluster_name = var.vcconfig_compute_cluster_name
  vcconfig_datacenter           = var.vcconfig_datacenter
  vcconfig_resourcepool         = var.vcconfig_resourcepool
  vcconfig_dvs                  = var.vcconfig_dvs
}