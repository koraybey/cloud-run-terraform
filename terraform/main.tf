provider "google" {
  credentials = file("service-account.json")
  project = var.PROJECT_ID
  region  = var.REGION
}

provider "google-beta" {
  credentials = file("service-account.json")
  project = var.PROJECT_ID
  region  = var.REGION
}


resource "google_cloud_run_service" "server" {
  name     = var.NAME
  location = var.REGION

  template {
    spec {
      containers {
        image = "gcr.io/${var.PROJECT_ID}/${var.NAME}:${var.VERSION}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.server.name
  location = google_cloud_run_service.server.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
