resource "google_storage_bucket" "bucket" {
  name     = "test-bucket-rohit"
  location = "australia-southeast1"
}

locals {
  bucketslist = yamldecode(file("../configs/gcs-buckets/bucket-details.yaml"))["buckets"]
  bucketitems = flatten([
    for bk, bucket in local.bucketslist : {
      bucketname     = bucket.bucket_name
      bucketlocation = bucket.location
    }
  ])

  bqdatasetlist = yamldecode(file("../configs/bq-datasets/bq-dataset-details.yaml"))["datasets"]
  bqdatasetitems = flatten([
    for ds, dataset in local.bqdatasetlist : {
      datasetname        = dataset.name
      datasetdescription = dataset.description
      datasetlocation    = dataset.location
    }
  ])

}

resource "google_storage_bucket" "bucket_list" {
  for_each = {
    for bucket in local.bucketitems : "${bucket.bucketname}/${bucket.bucketlocation}" => bucket
  }
  name     = each.value.bucketname
  location = each.value.bucketlocation
}

resource "google_bigquery_dataset" "dataset_list" {
  for_each = {
    for dataset in local.bqdatasetitems : "${dataset.datasetname}/${dataset.datasetdescription}" => dataset
  }

  dataset_id                  = each.value.datasetname
  friendly_name               = each.value.datasetname
  description                 = each.value.datasetdescription
  location                    = "EU"
  default_table_expiration_ms = 3600000

}

resource "google_service_account" "composer_service_account" {
  account_id   = "composerserviceaccount"
  display_name = "A service account that only composer can interact with"
}


data "google_iam_policy" "composer_sa_iam" {
  binding {
    role = "roles/composer.worker"

    members = [
      google_service_account.composer_service_account.name
    ]
  }
}

data "google_iam_policy" "project_sa_iam" {
  binding {
    role = "roles/composer.ServiceAgentV2Ext"

    members = [
      "serviceAccount:service-1047648526865@cloudcomposer-accounts.iam.gserviceaccount.com",
    ]
  }
}

resource "google_service_account_iam_member" "composer_service_account" {
  provider = google-beta
  service_account_id = google_service_account.composer_service_account.name
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-1047648526865@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_composer_environment" "data-workflow" {
  provider = google-beta
  name = "dev-environment"
  region = "australia-southeast1"
  project = var.project_id

  config {
    software_config {
      image_version = "composer-2.1.4-airflow-2.3.4"
    }
    node_config {
      service_account = google_service_account.composer_service_account.name
    }
  
  }
}