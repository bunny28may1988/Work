data "aws_iam_policy_document" "s3_bucket_policy_document" {
  count      = length(var.service_iam_policies.s3_bucket_rw) > 0 ? 1 : 0
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.service_iam_policies.s3_bucket_rw}-${var.environment}/*"
    ]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.service_iam_policies.s3_bucket_rw}-${var.environment}"
    ]
  }
}

resource "aws_iam_policy" "s3_bucket_rw_policy" {
  count      = length(var.service_iam_policies.s3_bucket_rw) > 0 ? 1 : 0
  name       = "s3-${var.service_iam_policies.s3_bucket_rw}-rw"
  policy     = data.aws_iam_policy_document.s3_bucket_policy_document[count.index].json
}

resource "aws_iam_role_policy_attachment" "s3_rw_policy_attachment" {
  count      = length(var.service_iam_policies.s3_bucket_rw) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.s3_bucket_rw_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}