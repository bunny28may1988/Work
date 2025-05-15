resource "aws_iam_role" "service_iam_role" {
  name               = "${var.namespace}-${var.service_name}-${var.environment}-iam-role"
  description        = "IAM Role for Service Account mapping"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.eks_oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.eks_oidc_provider}:aud": "sts.amazonaws.com",
          "${var.eks_oidc_provider}:sub": "system:serviceaccount:${var.namespace}:${var.service_name}-sa"
        }
      }
    }
  ]
}
EOF
  tags               = merge(local.default_tags, {
    Name = "${var.namespace}-${var.service_name}-${var.environment}-iam-role"
  })
}

resource "aws_iam_role_policy_attachment" "secrets_ro_policy_attachment" {
  count      = length(var.secret_arns) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.secret_ro_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}

resource "aws_iam_role_policy_attachment" "elb_rw_policy_attachment" {
  count      = var.service_iam_policies.elb_rw ? 1 : 0
  policy_arn = aws_iam_policy.elb_rw_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}

resource "aws_iam_role_policy_attachment" "rds_rw_policy_attachment" {
  count      = var.service_iam_policies.rds_rw ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  role       = aws_iam_role.service_iam_role.name
}

resource "aws_iam_role_policy_attachment" "logs_rw_policy_attachment" {
  count      = var.service_iam_policies.logs_rw ? 1 : 0
  policy_arn = aws_iam_policy.logs_rw_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}