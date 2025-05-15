data "aws_iam_policy" "readonly" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "aws_all_read_only_policy_attachment" {
  for_each   = {for k, v in var.policy_mappings : k => v if v.attach_all_ro_policy}
  policy_arn = data.aws_iam_policy.readonly.arn
  role       = data.aws_iam_role.this[each.key].name
}

data "aws_iam_role" "this" {
  for_each = {for k, v in var.policy_mappings : k => v if v.attach_all_ro_policy}
  name      = each.value.role_name
}