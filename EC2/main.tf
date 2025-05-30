module "ec2_devopsAgent"{
    source = "../../modules/EC2"
    ssh_key_name = var.ssh_key_name 
    create_instance = {
      (var.ec2_jump_server_name) = {
        ami = var.ec2_jump_server_ami
        instance_type = var.ec2_jump_server_instance_type
        availability_zone = var.ec2_jump_server_az
        get_password_data = false
        iam_instance_profile = var.ec2_iam_instance_profile
        user_data_base64 = base64encode(data.template_file.jump_server_user_data.rendered)
        root_block_device = [
          {
            volume_size = 30
            volume_type = "gp3"
            encrypted = true
            kms_key_id = var.ec2_kms_key_arn
            delete_on_termination = true 
          }
        ]
        metadata_options = [
          {
            http_tokens = "required" 
          }
        ]
        ec2_tags = merge(local.default_tags,{
          Name = var.ec2_jump_server_name 
        })
        volume_tags = merge(local.default_tags,{
          Name = "${var.ec2_jump_server_name}_volume"
        })
      }
    }
}