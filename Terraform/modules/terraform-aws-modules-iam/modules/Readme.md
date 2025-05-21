#########################################
# IAM policy
#########################################
```
module "iam_aft_role" {
  source = "../../../modules/IAM"

# If need to create IAM Role, [create_policy = true else create_policy = false]
  create_policy = false

  #######################   Role  ###################################
    trusted_role_arns = [
    "arn:aws:iam::account_id:root",
  ]

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

# If need to create IAM Role, [create_role = true else create_role = false]
 create_role = true
  role_name  = "role_name"
  role_requires_mfa = false

# If need to create_instance_profile = true, create_instance_profile = false.
  create_instance_profile = true
# If need to attach inline policy
  inline_policy = {}

# Attach multiple policy to Role
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"    
  ]

  tags = {
    "Name" = "role-ec2-aft-admin-dr-1",
    "Project Name" = "INF"
  }
 
}
```
