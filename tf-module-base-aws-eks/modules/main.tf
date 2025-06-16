# NOTE: DO NOT USE REFRECNES OF data blovk aws_eks_cluster" "cluster01" anywhere as this will cause dependcney issue 

locals {
  cluster_name = "eks-${var.application-name}-${var.environment}-01"
  userdata_al2023 = base64encode(templatefile("${path.module}/al2023_v${var.user_data_version}.tpl", { proxy_ip="${var.proxy_ip}",no_proxy_ip="${var.no_proxy_ip}",cluster_name = "${local.cluster_name}", api_ep = "${aws_eks_cluster.main.endpoint}" , cert_auth = aws_eks_cluster.main.certificate_authority[0].data , cidr =  data.aws_eks_cluster.cluster01.kubernetes_network_config[0].service_ipv4_cidr}) ) 
  userdata_bottlerocket = base64encode(templatefile("${path.module}/br_v${var.user_data_version}.toml.tpl", { proxy_ip="${var.proxy_ip}",no_proxy_ip="${var.no_proxy_ip}",cluster_name = "${local.cluster_name}", api_ep = "${aws_eks_cluster.main.endpoint}" , cert_auth = aws_eks_cluster.main.certificate_authority[0].data}))  
  eks_version=replace(var.cluster_version,".","-")
  partition = data.aws_partition.current.partition
    updated_ami_al2023= nonsensitive(data.aws_ssm_parameter.ami_store_al2023.value)
    updated_ami_br=nonsensitive(data.aws_ssm_parameter.ami_store_br.value)
    device_names = tolist([
    "/dev/xvda",
    "/dev/xvdb",
    "/dev/xvdc",
    "/dev/xvdd",
    "/dev/sde",
    "/dev/sdf",
    "/dev/sdg",
    "/dev/sdh",
    "/dev/sdi",
    "/dev/sdj",
    "/dev/sdk",
    "/dev/sdl"
    # (and so on for however many devices you expect to need to support,
    # presumably up to "z" at the worst)
  ])

}


data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}


data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}


data "aws_eks_cluster" "cluster01" {
  name = aws_eks_cluster.main.id
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "addonversion" {
  // for_each = {
  //   for k, v in var.addons : k => {
  //     name = v.name
  //     most_recent = try(v.most_recent, false)
  //   }
  // }

  for_each = var.addons
  addon_name = each.value.name
  kubernetes_version = var.cluster_version
  most_recent = each.value.most_recent
}

data "aws_vpc" "vpc01"{
  id = var.vpc_id
}

##SHARED SSM PARAMS for AMIs

data "aws_ssm_parameter" "ami_store_al2023" {
  name = "arn:aws:ssm:${var.region}:135306324064:parameter/eks-module/${var.cluster_version}"

}

data "aws_ssm_parameter" "ami_store_br" {
  name = "arn:aws:ssm:${var.region}:135306324064:parameter/eks-module/${var.cluster_version}/br"

}

data "aws_ssm_parameter" "ami_store_jumpserver" {
  name = "arn:aws:ssm:${var.region}:135306324064:parameter/eks-module/jumpserver"

}


# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${local.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policies for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${local.cluster_name}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.jumpserver.id]  

  }

  tags = {
    Name        = "${local.cluster_name}-eks-cluster-sg"
    Environment = var.environment
  }
}

#SECURITY GROUP FOR DEVOPS AGENTS TO EKS CLUSTER

resource "aws_security_group" "eks_cluster_sg3" {
  name        = "${local.cluster_name}-eks-cluster-sg3"
  description = "communication of devops agents with eks"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.azure_devops_agent_ips
    
  }

  tags = {
    Name        = "${local.cluster_name}-eks-cluster-sg3"
    Environment = var.environment
  }
}


# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    endpoint_public_access  = false
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.eks_cluster.id,aws_security_group.eks_cluster_sg3.id]
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_instance.jumpserver
  ]

  tags = {
      environment         = var.environment

  }
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {


  client_id_list  = ["sts.amazonaws.com"]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

}

# IAM Role for Node Group
resource "aws_iam_role" "eks_nodegroup" {
  name = "${local.cluster_name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policies for Node Group
resource "aws_iam_role_policy_attachment" "eks_nodegroup_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodegroup.name
}

# Node Group Security Group
resource "aws_security_group" "eks_nodegroup" {
  name        = "${local.cluster_name}-eks-nodegroup-sg"
  description = "Security group for EKS node group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.vpc01.cidr_block]

  }


  tags = {
      Name                = "${local.cluster_name}-eks-nodegroup-sg"

  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  for_each = var.nodegroups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.cluster_name}-${each.key}-primary-nodegroup"
  node_role_arn   = aws_iam_role.eks_nodegroup.arn
  // subnet_ids      = var.nodegroup_subnet_ids. adding additional control for NG subnets below
  subnet_ids      = each.value.subnets == null?var.nodegroup_subnet_ids:each.value.subnets
  # release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  launch_template {
    id = aws_launch_template.eks_nodegroup_lt[each.key].id
    version = aws_launch_template.eks_nodegroup_lt[each.key].latest_version
  }



  scaling_config {
    desired_size = each.value.desired_nodes
    max_size     = each.value.max_nodes
    min_size     = each.value.min_nodes
  }



  dynamic "taint" {
    for_each = each.value.taints # notice the sublist with the names
    content {
      key = taint.value[0]
      value  = taint.value[1]
      effect = taint.value[2]
    }
  }

  
  dynamic "update_config" {
    for_each = length(each.value.update_config) > 0 ? [each.value.update_config] : []

    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }
  labels = each.value.labels

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup_worker_policy,
    aws_iam_role_policy_attachment.eks_nodegroup_cni_policy,
    aws_iam_role_policy_attachment.eks_nodegroup_ecr_policy,
    aws_iam_role_policy_attachment.eks_nodegroup_ssm_policy
  ]

  tags = {
      Name                = "${local.cluster_name}-primary-nodegroup"

  }
}


#Lauch template for ASG
resource "aws_launch_template" "eks_nodegroup_lt" {
  for_each = var.nodegroups
  name = "${local.cluster_name}-${each.key}-eks_nodegroup"

  dynamic "block_device_mappings" {
    for_each = slice(local.device_names, 0, length(each.value.ebs_size)) # notice the sublist with the names
    content {
      device_name = block_device_mappings.value
        ebs {
        volume_size = each.value.ebs_size[index(local.device_names, block_device_mappings.value)]
        encrypted  = true
        kms_key_id = var.ebs_kms_key
        volume_type = "gp3"
      }
    }
  }
  image_id  = (var.node_ami_auto_update || var.cluster_version!=data.aws_ssm_parameter.s1.value)?(each.value.ami_family == "al2023"?(local.updated_ami_al2023):(local.updated_ami_br)):nonsensitive(data.aws_ssm_parameter.s[each.key].value)
  instance_type = each.value.instance_type
  vpc_security_group_ids = [aws_security_group.eks_nodegroup.id,aws_security_group.eks_cluster.id,aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  user_data = each.value.ami_family == "al2023"? local.userdata_al2023:local.userdata_bottlerocket

}

resource "aws_eks_addon" "addons" {
  for_each = var.addons
  cluster_name = aws_eks_cluster.main.id
  addon_name   = each.value.name
  addon_version = try(each.value.version, data.aws_eks_addon_version.addonversion[each.key].version)
  resolve_conflicts_on_update = try(each.value.resolve_conflicts, "OVERWRITE")
  resolve_conflicts_on_create = try(each.value.resolve_conflicts, "OVERWRITE")
  depends_on = [ aws_eks_node_group.main ]
}


##JUMP server related resources

##ec2 instance


resource "aws_instance" "jumpserver" {
  count = var.create_jumpserver?1:0
  depends_on = [ data.aws_lambda_invocation.lambdainvoke1 ]
  ami= length(var.jumpserver_ami)>1?var.jumpserver_ami:data.aws_ssm_parameter.ami_store_jumpserver.value
  instance_type = var.jumpserver_instancetype
  subnet_id = var.cluster_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.jumpserver.id,var.jumpserver_security_group]
  iam_instance_profile = var.jumpserver_instanceprofile
  user_data = var.jumpserver_userdata
  root_block_device{
    encrypted = true
    kms_key_id = var.ebs_kms_key
    volume_size = 20
  }
  ebs_block_device{
    device_name = "/dev/sdb"
    encrypted = true
    kms_key_id = var.ebs_kms_key
    volume_size = 50
  }
  tags = {
      Name                = "jumpserver-${local.cluster_name}-1"

  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to the 'tags' attribute
      ami,ebs_block_device
    ]
  }
}

# SG

resource "aws_security_group" "jumpserver" {
  name        = "security-group-jumpserver-${local.cluster_name}-01"
  description = "Jumpserver Security group"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
      Name                = "${local.cluster_name}-eks-cluster-sg"

  }
}


############IAM FUNCTION CREATION

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role-${local.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic Lambda execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_basic1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.lambda_role.name
}
# Create Lambda function
resource "aws_lambda_function" "lambda_eks" {
  filename      = "${path.module}/lambda_function.py.zip"
  function_name = "eks-${var.application-name}-${var.environment}-01"
  role         = aws_iam_role.lambda_role.arn
  handler      = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.py.zip")

  runtime = "python3.9"

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  timeout     = 30
  memory_size = 128
  depends_on = [
    aws_cloudwatch_log_group.lambda_logs
  ]


}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/eks-${var.application-name}-${var.environment}-01"
  retention_in_days = 14
}


##########END IAM

resource "aws_ssm_parameter" "name" {
  for_each = var.nodegroups
  name = "${local.cluster_name}-${each.key}-primary-nodegroup"
  type = "String"
  value =  each.value.ami_family=="al2023"? nonsensitive(data.aws_ssm_parameter.ami_store_al2023.value):nonsensitive(data.aws_ssm_parameter.ami_store_br.value)
  lifecycle {
    ignore_changes = [ value ]
  }
  
  
}

resource "aws_ssm_parameter" "eks_current" {

  name = "${local.cluster_name}-version"
  type = "String"
  value =  var.cluster_version
  lifecycle {
    ignore_changes = [ value ]
  }
  
  
}



data "aws_ssm_parameter" "s" {
  for_each = var.nodegroups
  name = "${local.cluster_name}-${each.key}-primary-nodegroup"
  depends_on = [ aws_ssm_parameter.name,data.aws_lambda_invocation.lambdainvoke1 ]

  
}

data "aws_ssm_parameter" "s1" {
  name = "${local.cluster_name}-version"
  depends_on = [ aws_ssm_parameter.eks_current,data.aws_lambda_invocation.lambdainvoke1]

  
}



data "aws_lambda_invocation" "lambdainvoke1" {
  function_name = "eks-${var.application-name}-${var.environment}-01"
  depends_on = [ aws_lambda_function.lambda_eks ]
  input = <<JSON
{
  "key1": "eks-${var.application-name}-${var.environment}-01",
  "key2": "${var.cluster_version}"
}
JSON
}

resource "aws_lambda_invocation" "lambdainvoke2" {
  depends_on = [ aws_eks_node_group.main,aws_launch_template.eks_nodegroup_lt ]
  for_each = var.nodegroups
  # lifecycle_scope = "CRUD"
  function_name = "eks-${var.application-name}-${var.environment}-01"
  input = jsonencode({
    key1 = "eks-${var.application-name}-${var.environment}-01"
    key2 = "aws_launch_template.eks_nodegroup_lt[each.key].latest_version"
  })
  
}

################################################################################
# Access Entry
################################################################################

locals {
  # This replaces the one time logic from the EKS API with something that can be
  # better controlled by users through Terraform
  bootstrap_cluster_creator_admin_permissions = {
    cluster_creator = {
      principal_arn = data.aws_iam_session_context.current.issuer_arn
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Merge the bootstrap behavior with the entries that users provide
  merged_access_entries = merge(
    { for k, v in local.bootstrap_cluster_creator_admin_permissions : k => v if var.enable_cluster_creator_admin_permissions },
    var.access_entries,
  )

  # Flatten out entries and policy associations so users can specify the policy
  # associations within a single entry
  flattened_access_entries = flatten([
    for entry_key, entry_val in local.merged_access_entries : [
      for pol_key, pol_val in lookup(entry_val, "policy_associations", {}) :
      merge(
        {
          principal_arn = entry_val.principal_arn
          entry_key     = entry_key
          pol_key       = pol_key
        },
        { for k, v in {
          association_policy_arn              = pol_val.policy_arn
          association_access_scope_type       = pol_val.access_scope.type
          association_access_scope_namespaces = lookup(pol_val.access_scope, "namespaces", [])
        } : k => v if !contains(["EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX"], lookup(entry_val, "type", "STANDARD")) },
      )
    ]
  ])
}

resource "aws_eks_access_entry" "this" {
  depends_on = [ aws_eks_cluster.main ]
  for_each = { for k, v in local.merged_access_entries : k => v  }

  cluster_name      = local.cluster_name
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
  user_name         = try(each.value.user_name, null)

  tags = merge( try(each.value.tags, {}))
}

resource "aws_eks_access_policy_association" "this" {
  depends_on = [ aws_eks_access_entry.this,aws_eks_cluster.main ]
  for_each = { for k, v in local.flattened_access_entries : "${v.entry_key}_${v.pol_key}" => v }

  access_scope {
    namespaces = try(each.value.association_access_scope_namespaces, [])
    type       = each.value.association_access_scope_type
  }

  cluster_name = local.cluster_name

  policy_arn    = each.value.association_policy_arn
  principal_arn = each.value.principal_arn

}