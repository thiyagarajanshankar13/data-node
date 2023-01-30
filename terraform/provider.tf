provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "atsans-bllueprint-tfstate"
    prefix = "terraform/state"
  }
}
