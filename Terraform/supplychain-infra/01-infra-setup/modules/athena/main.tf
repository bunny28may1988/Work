module "supplychain-athena" {
  source     = "../../../../../terraform-aws-modules-athena/modules"
  workgroups = {
    "workgroup" = {
      name          = var.workgroup_name
      description   = "Athena workgroup for Supplychain"
      state         = "ENABLED"
      tags          = {}
      force_destroy = true
      configuration = {
        bytes_scanned_cutoff_per_query  = 10485760
        enforce_workgroup_configuration = true
        engine_version                  = {
          selected_engine_version = "AUTO"
        }
        execution_role                     = ""
        publish_cloudwatch_metrics_enabled = true
        requester_pays_enabled             = false
        result_configuration               = {
          output_location = var.output_location
          # encryption_configuration = {
          #   encryption_option = "SSE_KMS"
          #   kms_key_arn       = "arn:aws:kms:ap-south-1:110664605661:key/27869e5c-63c5-4e03-b54a-71ede75db8a4"
        }
        acl_configuration = {
          s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
        }
        expected_bucket_owner = data.aws_caller_identity.current.account_id
      }
    }
  }
}