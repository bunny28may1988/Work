application = {
  id           = "APP-01396"
  name         = "DevOps"
  owner        = "Kannan Varadharajan"
  manager      = "Mohan Pemmaraju"
  tlt          = "Vijay Narayanan"
  rating       = "Medium"
  budget_type  = "ctb"
  map-migrated = "migPHEWKGG1FG"
}

cluster = {
  services = {
    aws-load-balancer-controller = {
      namespace = "kube-addons"
      policies  = {
        elb_rw = true
      }
    },
    kong = {
      namespace    = "kong-ingress"
      secret_names = [
        "domain-ssl-certificate-cer",
        "domain-ssl-certificate-key",
        "kong-enterprise-license",
        "kotak-standalone-ca-cer"
      ]
      policies = {}
    },
    otel-collector = {
      namespace = "supplychain-otel"
      policies  = {
        logs_rw = true
        eks_ro  = true
      }
    },
    chainloop-cas = {
      namespace = "supplychain"
      policies  = {}
    },
    chainloop-control-plane = {
      namespace    = "supplychain"
      secret_names = [
        "dsn"
      ]
      policies = {}
    },
    api-catalog = {
      namespace = "supplychaincommon"
      policies  = {
        s3_bucket_rw      = "apicatalog-s3-bucket"
        dynamodb_table_rw = "t_domain_mapping"
        kms_rw            = true
      }
    }
  }
}

