environment = {
  name = "nonprod"
}

aws = {
  region                   = "ap-south-1"
  assume_role_arn          = "arn:aws:iam::471112531675:role/role-service-inf-terraform-chainloop-uat-01"
  #https://dev.azure.com/kmbl-devops/network/_git/network-internal?path=/chainloop-nonprod-account/azure-pipelines.yaml
  network_tf_bucket        = "kmbl-terraform-state-s3-bucket"
  network_tf_bucket_key    = "network/network-internal/nonprod/chainloop/network-network-chainloop-01396-nonprod-dev.tfstate"
  network_tf_bucket_region = "ap-south-1"
}

security = {
  sg = {
    eks_cluster_sg_name = "supplychain-eks-cluster-sg-nonprod"
    jump_server_sg_name = "supplychain-jump-server-sg-nonprod"
    vpc_sg_name         = "supplychain-vpc-sg-nonprod"
    devops_sg_name      = "supplychain-devops-sg-nonprod"
    devops_agent_ips    = ["10.10.47.82/32", "10.10.47.220/32", "10.53.81.5/32"]
  }
  iam = {
    devops_iam_user_arn    = "arn:aws:iam::471112531675:user/user-service-chainloop-nonprod-01"
    devops_iam_user_name    = "user-service-chainloop-nonprod-01"
    read_only_iam_role_arn = "arn:aws:iam::471112531675:role/role-service-chainloop-readwrite-nonprod-01"
    read_only_iam_role_name = "role-service-chainloop-readwrite-nonprod-01"
  }
}

s3_bucket = {
  bucket1 = "s3-supplychain-nonprod"
  bucket2 = "apicatalog-s3-bucket-nonprod"
  bucket3 = "supplychain-db-tracker-s3-bucket"
  bucket4 = "supplychain-software-attributes"
  bucket5 = "supplychain-athena-query-results" # Delete this bucket post UAT Testing
  bucket6 = "supplychain-infosec-prisma"
  bucket7 = "supplychain-infosec-infra-av-nonprod"
  bucket8 = "supplychain-infosec-appvuln"
  bucket9 = "supplychain-athena-query-results-nonprod"
}

network = {
  nlb1 = "supplychain-nlb-nonprod"
  nlb2 = "supplychain-nlb-common"
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
      "ecr-ado-agent-nonprod",
      "kong-ingress-controller",
      "kong-gateway",
      "kong-gateway-hardened",
      "kube-state-metrics-amd64",
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
      "software-catalog-service",
      "software-catalog-ui",
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
      "metrics-server"
    ]
    has_mutable_tags          = true
    enable_region_replication = false
  }

  ec2 = {
    jump_server_name             = "supplychain-nonprod-jumpserver"
    jump_server_instance_type    = "t3a.medium"
    jump_server_ami_id           = "ami-09e034b1e98e8d08b"
    jump_server_private_ip_index = -16
  }

  eks = {
    cluster_name    = "eks-supplychain-nonprod"
    cluster_version = "1.32"
    node_groups     = [
      {
        name                 = "eks-node-group-dev-02"
        # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.29/amazon-linux-2/recommended/image_id --region ap-south-1 --query "Parameter.Value" --output text
        ami_id               = "ami-01d4aea4600d4dd60"
        min_size             = 2
        desired_size         = 2
        max_size             = 4
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
    output_location = "s3://supplychain-athena-query-results-nonprod/"
  }

  glue = {
    catalog_database_name = "supplychain-dbtracker"
    catalog_table_name    = "db-tracker-logs"
    location_uri          = "s3://supplychain-db-tracker-s3-bucket/"
  }
}

cross_account_secret_access = {
  secrets = {
    name                  = "kong-ingress/kong/nonprod/kong-enterprise-license",
    destination_role_arns = [
      "arn:aws:iam::061051219859:role/iam-role-eks-eway-dev-01",
      "arn:aws:iam::905418442245:role/iam-role-eks-kong-ingress-controller-finflux-prod-1",
      "arn:aws:iam::050451402947:role/iam-role-kong-riskcentral-dev-nonprod-1",
      "arn:aws:iam::050752612758:role/iam-role-kong-risk-central-prod",
      "arn:aws:iam::061051219859:role/eks-E-WayBill-uat-01-eks-cluster-role",
      "arn:aws:iam::339712812241:role/vlos-secret-manager-kong-eks-chainloop-uat-01",
      "arn:aws:iam::654654183601:role/iam-role-eks-vlos-prod-1",
      "arn:aws:iam::401437228732:role/kong-ingress-kong-prod-iam-role"
    ]
  }
}