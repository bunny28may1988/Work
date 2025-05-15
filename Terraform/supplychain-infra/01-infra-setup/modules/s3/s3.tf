module "supplychain-s3-bucket" {
  source = "../../../../../terraform-aws-modules-s3/modules"

  create_bucket = true
  bucket        = var.s3_bucket_name

  versioning = {
    status     = false
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_arn
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }

  bucket_tags = merge(local.default_tags, {
    Name = "${var.s3_bucket_name}"
  })
}