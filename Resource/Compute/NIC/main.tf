module "EC2_Agent_nic" {
  source = "../../../Modules/NIC-T104"
  network_interface = {
    (var.EC2_Agent_NIC_Name) = {
      nic_subnet_id         = var.EC2_Agent_NIC_Subnet
      private_ips           = var.EC2_Agent_Private_ips
      security_groups       = var.EC2_Agent_NIC_SG
      nic_description       = "ADO-BuildAgent Network Interface"
      source_dest_check_nic = false
      tags = {
        "Name" = "ADO-BuildAgent-NIC"
      }
      enable_elastic_ip = false
      Predefined_tags = merge(local.default_tags, {
        Name = var.EC2_Agent_NIC_Name
      })
    }
  }
}