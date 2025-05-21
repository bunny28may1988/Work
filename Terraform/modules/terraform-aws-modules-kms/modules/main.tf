################## Key Management Service ####################

resource "aws_kms_key" "keyname" {
  description         = try(var.description, null)
  enable_key_rotation = try(var.enable_key_rotation, true)
  policy              = try(var.user_policy, null)
  tags                = merge(var.tags, tomap({ "ApplicationComponent" = "kms", "Managed-BY" = "Terrafrom" }))

  lifecycle {
    ignore_changes = [
      policy
    ]

  }
}
resource "aws_kms_alias" "alias" {
  name          = format("alias/%s", var.key_name)
  target_key_id = aws_kms_key.keyname.key_id
}
