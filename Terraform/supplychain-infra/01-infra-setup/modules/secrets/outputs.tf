output "secret_arns" {
  value = [for secret in aws_secretsmanager_secret.app_secrets : secret.arn]
}