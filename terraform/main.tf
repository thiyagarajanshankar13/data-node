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

  bqdatasetlist = yamldecode(file("../configs/bq-buckets/bq-dataset-details.yaml"))["datasets"]
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