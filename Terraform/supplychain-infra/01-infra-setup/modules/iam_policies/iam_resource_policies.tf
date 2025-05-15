data "aws_secretsmanager_secret" "this" {
  for_each = toset(flatten([for k, v in var.policy_mappings : v.secret_names if v.attach_secrets_ro_resource_policy]))
  name     = each.value
}

data "aws_iam_policy_document" "cross_account_secret_ro_policy_document" {
  for_each = data.aws_secretsmanager_secret.this
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [each.value.arn]
    principals {
      type        = "AWS"
      identifiers = flatten([for k, v in var.policy_mappings : k])
    }
  }
}

data "aws_iam_policy_document" "cross_account_kms_decrypt_policy_document" {
  for_each = data.aws_secretsmanager_secret.this
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [each.value.kms_key_id]
    principals {
      type        = "AWS"
      identifiers = [for k, v in var.policy_mappings : k]
    }
  }

  # statement to allow the root user to manage the key
  statement {
    actions = [
      "kms:*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      ]
    }
  }
}

resource "aws_secretsmanager_secret_policy" "attach_cross_account_secret_policy" {
  for_each   = data.aws_secretsmanager_secret.this
  secret_arn = each.value.arn
  policy     = data.aws_iam_policy_document.cross_account_secret_ro_policy_document[each.key].json
}

resource "aws_kms_key_policy" "attach_cross_account_kms_policy" {
  for_each = data.aws_secretsmanager_secret.this
  key_id   = each.value.kms_key_id
  policy   = data.aws_iam_policy_document.cross_account_kms_decrypt_policy_document[each.key].json
}
