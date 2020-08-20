data "terraform_remote_state" "vcbuild" {
  backend = "local"

  config = {
    path = "../terraform-vcbuild-hytrust/terraform.tfstate"
  }
}

data "terraform_remote_state" "hytrust_env_1_dev" {
  backend = "remote"

  config = {
    organization = "RPTData"
    workspaces = {
      name = "hytrust_env_1_dev"
    }
  }
}