data "aws_iam_policy_document" "kms_policy_document" {
  count      = var.service_iam_policies.kms_rw ? 1 : 0
  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      "${var.kms_key_arn}"
    ]
  }
}

resource "aws_iam_policy" "kms_rw_policy" {
  count  = var.service_iam_policies.kms_rw ? 1 : 0
  name   = "kms-rw"
  policy = data.aws_iam_policy_document.kms_policy_document[count.index].json
}

resource "aws_iam_role_policy_attachment" "kms_rw_policy_attachment" {
  count      = var.service_iam_policies.kms_rw ? 1 : 0
  policy_arn = aws_iam_policy.kms_rw_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}