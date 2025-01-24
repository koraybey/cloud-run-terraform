output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.default.status[0].url
}

output "service_name" {
  description = "The name of the deployed Cloud Run service"
  value       = google_cloud_run_service.default.name
}

output "service_location" {
  description = "The location/region of the deployed Cloud Run service"
  value       = google_cloud_run_service.default.location
}

output "latest_revision_name" {
  description = "The name of the latest revision of the Cloud Run service"
  value       = google_cloud_run_service.default.status[0].latest_created_revision_name
}