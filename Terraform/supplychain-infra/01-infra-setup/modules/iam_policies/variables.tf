variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "policy_mappings" {
  type = map(object({
    # Should a policy to read secrets be attached to this role?
    attach_secrets_ro_resource_policy = optional(bool, false)
    # List of secrets to scope the policy to
    secret_names                      = optional(list(string), [])

    attach_all_ro_policy = optional(bool, false)
    attach_athena_ro_policy = optional(bool, false)

    # Name of the role to associate policies to.
    role_name            = optional(string)
    # Name of the user to associate policies to.
    user_name            = optional(string)

    athena_workgroup_name = optional(string)
    glue_catalog_database_name = optional(string)
    glue_catalog_table_name    = optional(string)
  }))
}