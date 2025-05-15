data "template_file" "pre_bootstrap_data" {
  template = file("${path.module}/pre-bootstrap.sh")
}

data "aws_ami" "eks_ami_latest" {
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_cluster_version}-v*"]
  }
  most_recent = true
}