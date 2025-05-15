data "aws_iam_policy_document" "eks_ro_policy_document" {
  count = var.service_iam_policies.eks_ro ? 1 : 0
  statement {
    actions = [
      "ec2:DescribeInstances",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:ListNodegroups",
      "eks:DescribeNodegroup",
      "eks:ListUpdates",
      "eks:DescribeUpdate",
      "eks:ListTagsForResource",
      "eks:TagResource",
      "eks:UntagResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_ro_policy" {
  count  = var.service_iam_policies.eks_ro ? 1 : 0
  name   = "${var.service_name}-eks-ro"
  policy = data.aws_iam_policy_document.eks_ro_policy_document[count.index].json
}

resource "aws_iam_role_policy_attachment" "eks_ro_policy_attachment" {
  count      = var.service_iam_policies.eks_ro ? 1 : 0
  policy_arn = aws_iam_policy.eks_ro_policy[count.index].arn
  role       = aws_iam_role.service_iam_role.name
}