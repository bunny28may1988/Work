data "aws_iam_policy_document" "athena_glue_ro_policy_document" {
  for_each = {for k, v in var.policy_mappings : k => v if v.attach_athena_ro_policy}
  statement {
    actions = [
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetDatabase",
      "athena:GetDataCatalog",
      "athena:GetTableMetadata",
      "athena:ListDatabases",
      "athena:ListDataCatalogs",
      "athena:ListTableMetadata",
      "athena:ListWorkGroups",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTablePartition",
      "glue:GetTablePartitions"
    ]
    resources = ["*"]
  }
}

data "aws_iam_user" "this" {
  for_each  = {for k, v in var.policy_mappings : k => v if v.attach_athena_ro_policy}
  user_name = each.value.user_name
}

resource "aws_iam_policy" "athena_glue_ro_policy" {
  for_each    = {for k, v in var.policy_mappings : k => v if v.attach_athena_ro_policy}
  name        = "athenaGlueReadOnlyPolicy"
  description = "Policy for Athena and Glue read-only permissions"
  policy      = data.aws_iam_policy_document.athena_glue_ro_policy_document[each.key].json
}

resource "aws_iam_user_policy_attachment" "athena_glue_ro_policy_attachment" {
  for_each   = {for k, v in var.policy_mappings : k => v if v.attach_athena_ro_policy}
  policy_arn = aws_iam_policy.athena_glue_ro_policy[each.key].arn
  user       = data.aws_iam_user.this[each.key].user_name
}