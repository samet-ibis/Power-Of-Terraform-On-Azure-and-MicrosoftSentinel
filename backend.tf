terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "t0neex "

    workspaces {
      name = "Terraform-AzureSentinel-"
    }
  }
}
