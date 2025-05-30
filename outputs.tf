output "network" {
  value = merge(data.terraform_remote_state.network.outputs, {
    vpc_cidr_block = data.aws_vpc.main.cidr_block
  })
}

output "compute" {
  value = {
    ec2 = {
      jump_server_arn   = module.ec2.jump_server_arn
      jump_server_sg_id = module.sg.jump_server_sg_id
    }
}
}
