variable "region" {
  type        = string
  description = "GCP region for deploying resources"
}

variable "version" {
  type        = string
  description = "Container image version/tag"
}

variable "name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}