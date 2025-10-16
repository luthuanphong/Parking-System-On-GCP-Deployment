# main.tf - Main Terraform configuration for Cloud Run deployment

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "container_registry_api" {
  service = "containerregistry.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

# Reference to existing service account
data "google_service_account" "existing_sa" {
  account_id = var.service_account_email
}

# Enable VPC Connector API
resource "google_project_service" "vpcaccess_api" {
  service = "vpcaccess.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

# VPC Connector for connecting to existing VPC
resource "google_vpc_access_connector" "parking_system_connector" {
  count         = var.create_vpc_connector ? 1 : 0
  name          = var.vpc_connector_name
  region        = var.region
  ip_cidr_range = var.vpc_connector_cidr
  network       = var.vpc_network_name

  depends_on = [
    google_project_service.vpcaccess_api
  ]
}

# Cloud Run Service
resource "google_cloud_run_v2_service" "parking_system" {
  name     = var.service_name
  location = var.region

  depends_on = [
    google_project_service.cloud_run_api
  ]

  template {
    service_account = data.google_service_account.existing_sa.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = "${var.container_image}:${var.image_tag}"

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
        cpu_idle = var.cpu_idle
      }

      # Environment variables
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Startup probe
      startup_probe {
        http_get {
          path = var.health_check_path
          port = var.container_port
        }
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      # Liveness probe
      liveness_probe {
        http_get {
          path = var.health_check_path
          port = var.container_port
        }
        initial_delay_seconds = 30
        timeout_seconds       = 5
        period_seconds        = 30
        failure_threshold     = 3
      }
    }

    # VPC connector (for connecting to existing VPC)
    /*
    dynamic "vpc_access" {
      for_each = var.create_vpc_connector || var.existing_vpc_connector_name != "" ? [1] : []
      content {
        connector = var.create_vpc_connector ? google_vpc_access_connector.parking_system_connector[0].id : var.existing_vpc_connector_name
        egress    = var.vpc_egress_setting
      }
    }
    */

    vpc_access {
      connector = "projects/${var.project_id}/locations/${var.region}/connectors/${var.existing_vpc_connector_name}."
      egress    = var.vpc_egress_setting
    }

    # Timeout
    timeout = "${var.request_timeout}s"

    # Labels
    labels = merge(var.labels, {
      managed-by = "terraform"
      service    = "parking-system",
      version    = var.image_tag
    })
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

# IAM policy for Cloud Run service (allow public access or specific users)
resource "google_cloud_run_service_iam_policy" "parking_system_policy" {
  location = google_cloud_run_v2_service.parking_system.location
  project  = google_cloud_run_v2_service.parking_system.project
  service  = google_cloud_run_v2_service.parking_system.name

  policy_data = data.google_iam_policy.parking_system_invoker.policy_data
}

data "google_iam_policy" "parking_system_invoker" {
  binding {
    role = "roles/run.invoker"
    members = var.allow_public_access ? [
      "allUsers"
    ] : var.allowed_members
  }
}

# Cloud Run domain mapping (optional)
resource "google_cloud_run_domain_mapping" "parking_system_domain" {
  count    = var.custom_domain != "" ? 1 : 0
  location = var.region
  name     = var.custom_domain

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.parking_system.name
  }
}