output "VPC_SG" {
  value = local.VpcSg_id
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