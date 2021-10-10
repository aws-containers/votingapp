output "iam_user_name" {
  description = "The GitHub user's name"
  value       = module.iam.iam_user_name
}

output "iam_access_key_id" {
  description = "The access key ID"
  value       = module.iam.iam_access_key_id
}

output "iam_access_key_secret" {
  description = "The access key secret"
  value       = module.iam.iam_access_key_secret
  sensitive   = true
}
