output "Private_Vpc-SG" {
  value = local.Private-VPC_SG
}

output "Public_Vpc-SG" {
  value = local.Public-VPC_SG
}

output "Public_SSH-SG" {
  value = local.Public-SSH_SG
}

output "Private_SSH-SG" {
  value = local.Private-SSH_SG
}

output "Private_subnet-ID-AZ1" {
  value = local.subnet_Private[0]
}
output "Private_subnet-ID-AZ2" {
  value = local.subnet_Private[1]
}

output "Public_subnet-ID" {
  value = local.subnet_Public[0]
}

output "InstanceProfile" {
  value = local.InstanceProfile
}
output "default_tags" {
  value = local.default_tags
} 