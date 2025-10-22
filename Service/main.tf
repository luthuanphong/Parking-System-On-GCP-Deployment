provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_secret_manager_secret" "db_user" {
  secret_id = "db_user"
  project   = var.project_id
}

data "google_secret_manager_secret" "db_pass" {
  secret_id = "db_password"
  project   = var.project_id
}

data "google_secret_manager_secret" "db_name" {
  secret_id = "db_name"
  project   = var.project_id
}

data "google_secret_manager_secret" "db_connection_name" {
  secret_id = "db_connection_name"
  project   = var.project_id
}

data "google_secret_manager_secret" "gcp_project_id" {
  secret_id = "gcp_project_id"
  project   = var.project_id
}

data "google_secret_manager_secret" "kms_location_id" {
  secret_id = "kms_location_id"
  project   = var.project_id
}

data "google_secret_manager_secret" "kms_key_ring_id" {
  secret_id = "kms_key_ring_id"
  project   = var.project_id
}

data "google_secret_manager_secret" "kms_key_id" {
  secret_id = "kms_key_id"
  project   = var.project_id
}

data "google_secret_manager_secret" "redis_host" {
  secret_id = "redis_host"
  project   = var.project_id
}

resource "google_cloud_run_v2_service" "main" {
  name     = "parking-service-api"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  deletion_protection=false
  template {
    service_account = var.service_account_email
    containers {
      image = "${var.image}:${var.tag}"
      resources {
        limits = {
          cpu    = "2"
          memory = "1024Mi"
        }
      }

      env {
        name = "DB_USER"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_user.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_pass.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "DB_NAME"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_name.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "DB_CONNECTION_NAME"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_connection_name.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GCP_PROJECT_ID"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.gcp_project_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "KMS_LOCATION_ID"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.kms_location_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "KMS_KEY_RING_ID"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.kms_key_ring_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "KMS_KEY_ID"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.kms_key_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "REDIS_HOST"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.redis_host.secret_id
            version = "latest"
          }
        }
      }
    }

    scaling {
      min_instance_count = 1
      max_instance_count = 3
    }

    vpc_access {
      network_interfaces {
        network    = "parking-system-private-network"
        subnetwork = "parking-system-private-network"
      }
    }
  }

  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
} 

resource "google_cloud_run_v2_service_iam_member" "authorize" {
  project = var.project_id
  location   = var.region
  name = google_cloud_run_v2_service.main.name
  role = "roles/run.invoker"
  member = "allUsers"
}