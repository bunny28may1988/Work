variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "catalog_id" {
  type        = string
  description = "glue caltalog id"
}

variable "catalog_database_name" {
  type        = string
  description = "glue database name"
}

variable "catalog_table_name" {
  type        = string
  description = "glue table name"
}

variable "location_uri" {
  type        = string
  description = "Athena workgroup output location"
}