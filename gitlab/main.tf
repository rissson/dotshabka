terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    endpoint                    = "https://gateway.eu1.storjshare.io"
    bucket                      = "terraform.infra.lama-corp.space"
    key                         = "gitlab.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true

    force_path_style = true
  }

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 3.6.0"
    }
  }
}

provider "vault" {}

data "vault_generic_secret" "infra_terraform_gitlab" {
  path = "infra/terraform/gitlab"
}

provider "gitlab" {
  token = data.vault_generic_secret.infra_terraform_cloudflare.data.token
}
