variable "region" {
  default = "ap-southeast-1"
}

variable "environment" {
  type = string
}

variable "github_connection_arn" {
  type = string
}

variable "github_code_repo_url" {
  type = string
}

variable "github_code_branch" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}

variable "should_use_ecr" {
  type = bool
  default = false
}
