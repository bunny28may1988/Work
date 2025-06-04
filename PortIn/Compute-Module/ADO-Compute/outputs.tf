
output "compute" {
  value = {
    sg = {
      EC2_ADO-Compute_SG-ID = module.ADO-Agent_SG["EC2_ADO-Compute_SG-ID"]
    }
  }
}

output "sg_compute" {
  value = local.compute_sg["EC2_ADO-Compute_SG-ID"].sg_ADO-Agent_SG
}