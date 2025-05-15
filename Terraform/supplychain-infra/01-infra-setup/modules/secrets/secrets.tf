resource "aws_secretsmanager_secret" "app_secrets" {
  for_each                = toset(var.secret_names)
  name                    = "${var.secret_name_prefix}${each.value}"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 30
  tags                    = merge(local.default_tags, {
    Name = "${var.secret_name_prefix}${each.value}"
  })
}