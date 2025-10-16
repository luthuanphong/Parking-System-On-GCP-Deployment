# outputs.tf - Output values from the Terraform configuration

output "service_name" {
  description = "Name of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.parking_system.name
}

output "service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.parking_system.uri
}

output "service_id" {
  description = "ID of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.parking_system.id
}

output "service_location" {
  description = "Location of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.parking_system.location
}

output "service_account_email" {
  description = "Email of the service account used by Cloud Run"
  value       = data.google_service_account.existing_sa.email
}

output "latest_ready_revision" {
  description = "Name of the latest ready revision"
  value       = google_cloud_run_v2_service.parking_system.latest_ready_revision
}

output "latest_created_revision" {
  description = "Name of the latest created revision"
  value       = google_cloud_run_v2_service.parking_system.latest_created_revision
}

output "traffic_statuses" {
  description = "Traffic allocation status"
  value       = google_cloud_run_v2_service.parking_system.traffic_statuses
}

output "custom_domain_url" {
  description = "Custom domain URL (if configured)"
  value       = var.custom_domain != "" ? "https://${var.custom_domain}" : null
}

output "vpc_connector_id" {
  description = "ID of the VPC connector (if created)"
  value       = var.create_vpc_connector ? google_vpc_access_connector.parking_system_connector[0].id : null
}

output "vpc_connector_name" {
  description = "Name of the VPC connector being used"
  value       = var.create_vpc_connector ? google_vpc_access_connector.parking_system_connector[0].name : var.existing_vpc_connector_name
}