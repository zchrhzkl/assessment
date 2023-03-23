terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.49.0"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = file(var.GOOGLE_APPLICATION_CREDENTIALS)
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}