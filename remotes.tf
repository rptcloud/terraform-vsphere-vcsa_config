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

data "terraform_remote_state" "vmware_tfc_env1" {
  backend = "remote"

  config = {
    organization = "RPTData"
    workspaces = {
      name = "vmware-lab-buildout-env1"
    }
  }
}