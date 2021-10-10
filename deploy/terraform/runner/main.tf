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

module "iam" {
  source = "./iam"

  iam_user_name = var.iam_user_name
}
