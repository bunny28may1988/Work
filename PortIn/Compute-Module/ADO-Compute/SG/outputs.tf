output "EC2_ADO-Compute_SG-ID" {
    description = "The ID of the Security Group for ADO Compute"
    value       = { for idx, id in module.security_groups.sg_id :
    "sg_${idx}" => id }
}