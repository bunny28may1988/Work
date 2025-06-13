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

output "subnet-az1" {
  value = local.subnet[0]
}
output "subnet-az2" {
  value = local.subnet[1]
}
output "InstanceProfile" {
  value = local.InstanceProfile
}
output "default_tags" {
  value = local.default_tags
} 