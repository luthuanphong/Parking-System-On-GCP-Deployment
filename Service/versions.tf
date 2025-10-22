# versions.tf - Terraform and provider version constraints

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket = "parking-system-deploy-tfstate"
    prefix = "terraform/state"
  }
}