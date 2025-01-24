resource "google_cloud_run_service" "default" {
  name     = var.name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.name}:${var.image_version}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}