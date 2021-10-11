output "app_url" {
  description = "The URL of the application"
  value       = var.should_use_ecr ? aws_apprunner_service.private_ecr_example[0].service_url : aws_apprunner_service.code_example[0].service_url
}
