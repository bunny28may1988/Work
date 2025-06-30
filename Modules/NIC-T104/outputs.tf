##NIC 

output "nic_id" {
  description = "ID of the Network Interface"
  value = [for i in aws_network_interface.network_card : i.id]
}

output "nic" {
  description = "AWS network interface resource details."
  value = aws_network_interface.network_card
}

output "nic_arn" {
  description = "ARN of the Network Interface"
  value = [for i in aws_network_interface.network_card : i.arn]
}

output "nic_mac_address" {
  description = "MAC address of the Network Interface"
  value = [for i in aws_network_interface.network_card : i.mac_address]
}


## EIP 
output "public_ips" {
  description = "Public IP addresses"
  value       = [for i in aws_eip.eip : i.public_ip]
}

output "eip_id" {
  description = "ID of the Elastic IP"
  value = [for i in aws_eip.eip : i.id]
}

output "eip_allocation" {
  description = "Allocation ID of the Elastic IP"
  value = [for i in aws_eip_association.eip-association : i.allocation_id ]
}