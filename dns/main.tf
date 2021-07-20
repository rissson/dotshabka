terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    endpoint                    = "https://gateway.eu1.storjshare.io"
    bucket                      = "terraform.infra.lama-corp.space"
    key                         = "dns.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true

    force_path_style = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.24.0"
    }
  }
}

provider "vault" {}

data "vault_generic_secret" "infra_terraform_cloudflare" {
  path = "infra/terraform/cloudflare"
}

provider "cloudflare" {
  api_token = data.vault_generic_secret.infra_terraform_cloudflare.data.api_token
}
