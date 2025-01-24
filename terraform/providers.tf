terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.8.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 6.1.0"
    }
  }
}