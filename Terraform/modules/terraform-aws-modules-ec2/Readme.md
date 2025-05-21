#Usage
Prerequisites

### Terraform installed locally.

Example:

***EC2 Instance***

######################################
###### Create EC2 Instance ###########
######################################

module "aft-devops-agent-1" {

  source = "../../../modules/ec2"

  create_instance = {

    "azure-devops-1" = {

        ami           = "ami-0399b1e1869486b66"

        instance_type = "m5a.large"

        availability_zone = "ap-south-1a"

        get_password_data = false

        root_block_device = [

          {

            volume_size = 10

            volume_type = "gp3"

            delete_on_termination = true

            kms_key_id = module.create_kms.key_id

            encrypted = true

          }

        ]

        network_interface = [

          {

            device_index          = 0

            network_interface_id  = module.eni.nic_id["eni-aft-devops-1a"].id

          }

        ]

 

        ec2_tags = {

          "Name" = "ec2-aft-azure-devops",

        }

 

        volume_tags = {

          "Name" = "ec2-aft-azure-devops",

        }

    }

  }

}


#########################################

