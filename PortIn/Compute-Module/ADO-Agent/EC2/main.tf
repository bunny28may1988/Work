module "EC2_ADO-Agent" {
    source = "../modules/EC2"
    ssh_key_name = null
    create_instance = {
        (var.EC2_ADO-Agent_name) = {
            ami = var.EC2_ADO-Agent_ami
            instance_type = var.EC2_ADO-Agent_instance_type
            vpc_security_group_ids = var.EC2_ADO-Agent_security_group_ids
            subnet_id = var.EC2_ADO-Agent_subnet_id
            root_block_device = [ {
                delete_on_termination = true
                volume_size = var.EC2_ADO-Agent_root_volume_size
                volume_type = var.EC2_ADO-Agent_root_volume_type
                encrypted = var.EC2_ADO-Agent_root_volume_encrypted
                kms_key_id = var.EC2_ADO-Agent_root_volume_kms_key_id
                iops = var.EC2_ADO-Agent_root_volume_iops
                throughput = var.EC2_ADO-Agent_root_volume_throughput
                tags = merge(local.default_tags, {
                    Name = "${var.EC2_ADO-Agent_name}_volume"
                    Module = "ADO-Agent"
                })
            }]
            tags = merge(local.default_tags,{
                Name = var.EC2_ADO-Agent_name
                Module = "ADO-Agent"
            })

        }
    }
}