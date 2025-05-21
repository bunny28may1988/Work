#Usage
Prerequisites

### Terraform installed locally.

Example:

***KMS Key***

########################
###### KMS ###########
#######################

module "create_kms" {
    source = "../kms"

  key_name  = "aft-kms-key"
  enable_key_rotation = true
  description = "KMS key for AFT account"

  #User policy is optional if you want to attach policy to KMS then add this block with your policy 
  user_policy = <<EOF
{
  "Id": "key-consolepolicy-3",

  "Version": "2012-10-17",

  "Statement": [

    {

      "Sid": "Enable IAM User Permissions",

      "Effect": "Allow",

      "Principal": {

        "AWS": "arn:aws:iam::*************:Test"

      },

      "Action": "kms:*",

      "Resource": "*"

    }

  ]

}

EOF
  tags = {
    Name = "aft-kms-key",
    created-by-terraform = "yes",
    terraform-version = "1.5"
  }
}

