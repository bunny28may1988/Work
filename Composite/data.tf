data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.aws.network_tf_bucket
    key    = var.aws.network_tf_bucket_key
    region = var.aws.network_tf_bucket_region
  }
}