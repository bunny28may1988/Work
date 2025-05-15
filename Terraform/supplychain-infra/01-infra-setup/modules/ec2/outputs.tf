output "jump_server_arn" {
  value = module.ec2_jump_server.instance_id[var.ec2_jump_server_name].arn
}