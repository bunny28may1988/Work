output "repository_urls" {
  value = [for repo in module.ecr_repositories : repo.repository_url]
}