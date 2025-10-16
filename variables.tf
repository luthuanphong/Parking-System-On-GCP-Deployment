variable "project_id" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "region" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "image" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "tag" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "service_account_email" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "limit" {
  type        = map(string)
  description = "Resource limits to the container"
  default     = null
}