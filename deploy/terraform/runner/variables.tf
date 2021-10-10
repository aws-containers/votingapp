variable "region" {
  default = "ap-northeast-1"
}

variable "ecr_repo_name" {
  type = string
}

variable "iam_user_name" {
  type    = string
  default = "github_action"
}
