output "vpc_id" {
  value = local.vpc_id
}
output "ado_agent_subnets" {
  value = local.ADO-Agent_Subnets
}
output "ado_sn_az1" {
  value = local.ADO-Agent_Subnets[0]
}
output "ado_sn_az2" {
  value = local.ADO-Agent_Subnets[1]
}
output "arcon_sg" {
  value = local.arcon_sg
}
output "vpc_sg" {
  value = local.vpc_sg
}
output "iam_ssm_role_name" {
  value = local.iam_ssm_role_name
}
output "iam_ssm_role_arn" {
  value = local.iam_ssm_role_arn
}
output "kms_key_arn" {
  value = local.kms_key_arn
}