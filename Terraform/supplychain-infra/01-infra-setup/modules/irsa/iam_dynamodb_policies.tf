data "aws_iam_policy_document" "dynamodb_policy_document" {
  count      = length(var.service_iam_policies.dynamodb_table_rw) > 0 ? 1 : 0
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${local.region}:${local.account_id}:table/${var.service_iam_policies.dynamodb_table_rw}"
    ]
  }
}

resource "aws_iam_policy" "dynamodb_rw_policy" {
  count  = length(var.service_iam_policies.dynamodb_table_rw) > 0 ? 1 : 0
  name   = "dynamodb-${var.service_iam_policies.dynamodb_table_rw}-rw"
  policy = data.aws_iam_policy_document.dynamodb_policy_document[count.index].json
}

resource "aws_iam_role_policy_attachment" "dynamodb_rw_policy_attachment" {
  count      = length(var.service_iam_policies.dynamodb_table_rw) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.dynamodb_rw_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}