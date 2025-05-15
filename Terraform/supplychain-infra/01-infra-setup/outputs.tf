output "network" {
  value = merge(data.terraform_remote_state.network.outputs, {
    vpc_cidr_block = data.aws_vpc.main.cidr_block

    nlb = module.nlb
  })
}

output "compute" {
  value = {
    ecr = {
      repository_urls = module.ecr.repository_urls
    }
    ec2 = {
      jump_server_arn   = module.ec2.jump_server_arn
      jump_server_sg_id = module.sg.jump_server_sg_id
    }
    eks = {
      cluster_endpoint = module.eks.cluster_endpoint
      cluster_sg_id    = module.eks.cluster_sg_id
      node_sg_id       = module.eks.node_sg_id
    }
  }
}