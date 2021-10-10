terraform {
  backend "s3" {
    key = "terraform/environment/dev/votingapp/runner.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "repo" {
  name = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "iam" {
  source = "./iam"

  iam_user_name = var.iam_user_name
}
