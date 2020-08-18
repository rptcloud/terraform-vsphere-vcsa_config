module "vcconfig" {
  source = "./modules/vcconfig"
  # depends_on                    = [module.vcbuild]
  vcconfig_compute_cluster_name = var.vcconfig_compute_cluster_name
  vcconfig_datacenter           = var.vcconfig_datacenter
  vcconfig_vcssopassword        = var.vcconfig_vcssopassword
  vcconfig_vcip                 = var.vcconfig_vcip
  vcconfig_vcssousername        = var.vcconfig_vcssousername
  vcconfig_resourcepool         = var.vcconfig_resourcepool
  vcconfig_dvs                  = var.vcconfig_dvs
}