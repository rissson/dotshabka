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

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "1.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
}

provider "minio" {
  minio_server     = "s3.lama-corp.space"
  minio_access_key = random_password.fsn-k3s_minio_admin-creds[0].result
  minio_secret_key = random_password.fsn-k3s_minio_admin-creds[1].result
}
provider "random" {}
provider "vault" {}
