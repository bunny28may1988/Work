environment = {
  name = "prod"
}

aws = {
  region                   = "ap-south-1"
  assume_role_arn          = "arn:aws:iam::992382402880:role/role-service-inf-terraform-chainloop-prod-01"
  #https://dev.azure.com/kmbl-devops/network/_git/network-internal?path=/chainloop-nonprod-account/azure-pipelines.yaml
  network_tf_bucket        = "kmbl-terraform-state-s3-bucket"
  network_tf_bucket_key    = "network/network-internal/prod/chainloop-1396/network-network-chainloop-1396-prod.tfstate"
  network_tf_bucket_region = "ap-south-1"
}

security = {
  sg = {
    eks_cluster_sg_name = "supplychain-eks-cluster-sg"
    jump_server_sg_name = "supplychain-jump-server-sg"
    vpc_sg_name         = "supplychain-vpc-sg"
    devops_sg_name      = "supplychain-devops-sg"
    devops_agent_ips    = ["10.10.35.132/32", "10.10.35.190/32", "10.53.81.5/32"]
  }
  iam = {
    devops_iam_user_arn    = "arn:aws:iam::992382402880:user/user-service-chainloop-eks-prod-01"
    devops_iam_user_name    = "user-service-chainloop-eks-prod-01"
    read_only_iam_role_arn = "arn:aws:iam::992382402880:role/role-service-chainloop-readonly-prod-01"
    read_only_iam_role_name = "role-service-chainloop-readonly-prod-01"
  }
}

s3_bucket = {
  bucket1 = "s3-supplychain-prod"
  bucket2 = "apicatalog-s3-bucket-prod"
  bucket3 = "supplychain-db-tracker-s3-bucket-prod"
  bucket4 = "supplychain-software-attributes-prod"
  bucket5 = "supplychain-athena-query-results-prod"
}

network = {
  nlb1 = "supplychain-nlb-common"
}

compute = {
  ecr = {
    repositories = [
      "artifact-cas",
      "control-plane-migrations",
      "control-plane",
      "frontend",
      "backend-migrations",
      "backend",
      "ecr-ado-agent",
      "kong-ingress-controller",
      "kong-gateway",
      "aws-load-balancer-controller",
      "secrets-store-csi-driver-provider-aws",
      "csi-secrets-store-driver",
      "csi-secrets-store-driver-crds",
      "otel-opentelemetry-collector-k8s",
      "otel-opentelemetry-collector-contrib",
      "twistlock-defender",
      "sig-storage-csi-node-driver-registrar",
      "sig-storage-livenessprobe",
      "ebs-csi-driver",
      "atlantis",
      "software-attributes-service",
      "supplychain-common-ui",
      "dependency-track-api-server",
      "dependency-track-frontend",
      "api-catalog-admin-service",
      "api-catalog-mapping-service",
      "api-catalog-artefact-service",
      "api-catalog-mock-server",
      "oryd-hydra",
      "chainloop-cli",
      "nats",
      "kong-gateway-hardened",
      "kube-state-metrics-amd64"
    ]
    has_mutable_tags          = true
    enable_region_replication = false
  }

  ec2 = {
    jump_server_name             = "supplychain-jumpserver"
    jump_server_instance_type    = "t3a.medium"
    jump_server_ami_id           = "ami-0580abca8c40953e1"
    jump_server_private_ip_index = -16
  }

  eks = {
    cluster_name    = "eks-supplychain"
    cluster_version = "1.32"
    node_groups     = [
      {
        name                 = "eks-node-group-01"
        # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.29/amazon-linux-2/recommended/image_id --region ap-south-1 --query "Parameter.Value" --output text
        ami_id               = "ami-0c7d49d994fac6ce4"
        min_size             = 2
        desired_size         = 2
        max_size             = 2
        instance_type        = "t3a.2xlarge"
        xvda_ebs_volume_size = 50
        xvdf_ebs_volume_size = 30
        ebs_volume_type      = "gp3"
        ebs_iops             = 3000
        ebs_throughput       = 125
      }
    ]
  }
}

data_catalog = {
  athena = {
    workgroup_name  = "supplychain-athena-workgroup"
    output_location = "s3://supplychain-athena-query-results-prod/"
  }

  glue = {
    catalog_database_name = "supplychain-dbtracker"
    catalog_table_name    = "db-tracker-logs"
    location_uri          = "s3://supplychain-db-tracker-s3-bucket-prod/"
  }
}


generic_secrets = {
  apps = {
    cicd-templates = {
      namespace    = "central-ecr"
      secret_names = [
        "aws-access-key-id",
        "aws-secret-access-key",
        "aws-account-id",
        "aws-default-region"
      ]
    }
    global = {
       namespace    = "shared"
       secret_names = [
        "ado-readonly-pat"
      ]
    }  
  }
}