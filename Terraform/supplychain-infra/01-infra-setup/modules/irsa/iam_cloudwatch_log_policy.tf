data "aws_iam_policy_document" "logs_rw_policy_document" {
  count = var.service_iam_policies.logs_rw ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs_rw_policy" {
  count  = var.service_iam_policies.logs_rw ? 1 : 0
  name   = "${var.service_name}-logs-rw"
  policy = data.aws_iam_policy_document.logs_rw_policy_document[count.index].json
}