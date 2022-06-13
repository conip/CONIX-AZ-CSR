data "terraform_remote_state" "ars" {
  backend = "local"

  config = {
    path = "../CONIX-AZ-ARS/terraform.tfstate"
  }
}