resource "google_storage_bucket" "bucket" {
  name     = "test-bucket-rohit"
  location = "australia-southeast1"
}

locals {
  bucketslist = yamldecode(file("./configs/gcs-buckets/bucket-details.yaml"))["buckets"]
  bucketitems = flatten([
    for bucket in local.bucketslist : {
      bucketname = bucket.bucket_name
      bucketlocation = bucket.location
    }
  ])
}

resource "google_storage_bucket_list" "bucket" {
  for_each = {
    for bucket in local.bucketitems : "${bucket.bucketname}/${bucket.bucketlocation}" => bucket
  }
  name     = "${each.value.bucketname}"
  location = "${each.value.bucketlocation}"
}