data "terraform_remote_state" "vmware_tfc_env1" {
  backend = "remote"

  config = {
    organization = "RPTData"
    workspaces = {
      name = "vmware-lab-buildout-env1"
    }
  }
}