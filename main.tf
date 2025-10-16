# main.tf - Main Terraform configuration for Cloud Run deployment

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_secret_manager_secret_version" "db_user" {
  secret  = "db_user"
  version = "latest"
}

data "google_secret_manager_secret_version" "db_pass" {
  secret  = "db_password"
  version = "latest"
}

data "google_secret_manager_secret_version" "db_name" {
  secret  = "db_name"
  version = "latest"
}

data "google_secret_manager_secret_version" "db_connection_name" {
  secret  = "db_connection_name"
  version = "latest"
}

data "google_secret_manager_secret_version" "gcp_project_id" {
  secret  = "gcp_project_id"
  version = "latest"
}

data "google_secret_manager_secret_version" "kms_location_id" {
  secret  = "kms_location_id"
  version = "latest"
}

data "google_secret_manager_secret_version" "kms_key_ring_id" {
  secret  = "kms_key_ring_id"
  version = "latest"
}

data "google_secret_manager_secret_version" "kms_key_id" {
  secret  = "kms_key_id"
  version = "latest"
}

data "google_secret_manager_secret_version" "redis_host" {
  secret  = "redis_host"
  version = "latest"
}

locals {
  DB_USER             = try(jsondecode(data.google_secret_manager_secret_version.db_user), data.google_secret_manager_secret_version.db_user).secret_data
  DB_PASS             = try(jsondecode(data.google_secret_manager_secret_version.db_pass), data.google_secret_manager_secret_version.db_pass).secret_data
  DB_NAME             = try(jsondecode(data.google_secret_manager_secret_version.db_name), data.google_secret_manager_secret_version.db_name).secret_data
  DB_CONNECTION_NAME  = try(jsondecode(data.google_secret_manager_secret_version.db_connection_name), data.google_secret_manager_secret_version.db_connection_name).secret_data
  GCP_PROJECT_ID      = try(jsondecode(data.google_secret_manager_secret_version.gcp_project_id), data.google_secret_manager_secret_version.gcp_project_id).secret_data
  KMS_LOCATION_ID     = try(jsondecode(data.google_secret_manager_secret_version.kms_location_id), data.google_secret_manager_secret_version.kms_location_id).secret_data
  KMS_KEY_RING_ID     = try(jsondecode(data.google_secret_manager_secret_version.kms_key_ring_id), data.google_secret_manager_secret_version.kms_key_ring_id).secret_data
  KMS_KEY_ID          = try(jsondecode(data.google_secret_manager_secret_version.kms_key_id), data.google_secret_manager_secret_version.kms_key_id).secret_data
  REDIS_HOST          = try(jsondecode(data.google_secret_manager_secret_version.redis_host), data.google_secret_manager_secret_version.redis_host).secret_data
}

module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.21"

  # Required variables
  service_name          = "parking-service-api"
  project_id            = var.project_id
  location              = var.region
  image                 = "${var.image}:${var.tag}"
  service_account_email = var.service_account_email
  container_concurrency = 100
  limits                = var.limit
  env_vars = [
    {
      name  = "DB_USER"
      value = local.DB_USER
    }
    ,
    {
      name  = "DB_PASS"
      value = local.DB_PASS
    }
    ,
    {
      name  = "DB_NAME"
      value = local.DB_NAME
    }
    ,
    {
      name  = "DB_CONNECTION_NAME"
      value = local.DB_CONNECTION_NAME
    }
    ,
    {
      name  = "GCP_PROJECT_ID"
      value = local.GCP_PROJECT_ID
    }
    ,
    {
      name  = "KMS_LOCATION_ID"
      value = local.KMS_LOCATION_ID
    }
    ,
    {
      name  = "KMS_KEY_RING_ID"
      value = local.KMS_KEY_RING_ID
    }
    ,
    {
      name  = "KMS_KEY_ID"
      value = local.KMS_KEY_ID
    }
    ,
    {
      name  = "REDIS_HOST"
      value = local.REDIS_HOST
    }

  ]
  members = ["allUsers"]
}