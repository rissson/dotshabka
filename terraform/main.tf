terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    endpoint                    = "https://gateway.eu1.storjshare.io"
    bucket                      = "terraform.infra.lama-corp.space"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true

    force_path_style = true
  }
}

provider "vault" {}
