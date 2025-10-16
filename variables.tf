# variables.tf - Input variables for the Terraform configuration

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "service_account_email" {
  description = "Email of the existing service account to use for Cloud Run"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the Cloud Run service"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
  default     = "parking-system-api"
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
  # Example: gcr.io/PROJECT_ID/parking-system:latest
}

variable "image_tag" {
  description = "The container image to deploy"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "512Mi"
}

variable "cpu_idle" {
  description = "CPU allocation when the container is idle"
  type        = bool
  default     = true
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "request_timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default = {
    NODE_ENV = "production"
    PORT     = "8080"
  }
}

variable "allow_public_access" {
  description = "Allow public access to the Cloud Run service"
  type        = bool
  default     = true
}

variable "allowed_members" {
  description = "List of members allowed to invoke the service (if not public)"
  type        = list(string)
  default     = []
}

variable "vpc_connector_name" {
  description = "Name for the VPC connector (if creating new one)"
  type        = string
  default     = "parking-system-connector"
}

variable "create_vpc_connector" {
  description = "Whether to create a new VPC connector"
  type        = bool
  default     = false
}

variable "existing_vpc_connector_name" {
  description = "Full path to existing VPC connector (e.g., projects/PROJECT_ID/locations/REGION/connectors/CONNECTOR_NAME)"
  type        = string
  default     = ""
}

variable "vpc_network_name" {
  description = "Name of the existing VPC network to connect to"
  type        = string
  default     = "default"
}

variable "vpc_connector_cidr" {
  description = "CIDR range for the VPC connector (must not overlap with existing subnets)"
  type        = string
  default     = "10.8.0.0/28"
}

variable "vpc_egress_setting" {
  description = "VPC egress setting (ALL_TRAFFIC or PRIVATE_RANGES_ONLY)"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"

  validation {
    condition     = contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.vpc_egress_setting)
    error_message = "VPC egress setting must be either ALL_TRAFFIC or PRIVATE_RANGES_ONLY."
  }
}

variable "custom_domain" {
  description = "Custom domain for the Cloud Run service (optional)"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "production"
    application = "parking-system"
  }
}