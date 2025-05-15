locals {
  default_tags = merge(var.default_tags, {
    Module = "ecr"
  })
}
