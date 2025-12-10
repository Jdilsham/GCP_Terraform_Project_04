variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "terraform-480812"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-southeast1-a"
}

variable "network" {
  description = "VPC Network Name"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork Name"
  type        = string
  default     = "default"
}