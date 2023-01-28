provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "atsans-376108-tfstate"
    prefix = "terraform/state"
  }
}
