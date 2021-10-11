terraform {
  backend "s3" {
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

module "dynamodb" {
  source = "./dynamodb"
  table_suffix = var.environment
}

module "runtime_iam_role" {
  source = "./iam"
  dynamodb_table_arn = module.dynamodb.restaurant_table_arn
  role_suffix = var.environment
}

resource "aws_apprunner_service" "code_example" {
  count = var.should_use_ecr ? 0 : 1
  service_name = "apprunner_code_${var.environment}"

  source_configuration {
    authentication_configuration {
      connection_arn = var.github_connection_arn
    }
    code_repository {
      code_configuration {
        code_configuration_values {
          build_command = "yum install pycairo -y && pip3 install -r requirements.txt"
          port          = "8080"
          runtime       = "PYTHON_3"
          start_command = "python app.py"
          runtime_environment_variables = {
            DDB_AWS_REGION = var.region
            DDB_TABLE_NAME = module.dynamodb.restaurant_table_name
          }
        }
        configuration_source = "API"
      }
      repository_url = var.github_code_repo_url
      source_code_version {
        type  = "BRANCH"
        value = var.github_code_branch
      }
    }
  }

  instance_configuration {
    instance_role_arn = module.runtime_iam_role.iam_role_arn
  }
}

data "aws_iam_policy_document" "apprunner_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "build.apprunner.amazonaws.com",
        "tasks.apprunner.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy" "AWSAppRunnerServicePolicyForECRAccess" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role" "apprunner_role" {
  name = "apprunner_role"

  assume_role_policy = data.aws_iam_policy_document.apprunner_policy.json
}

resource "aws_iam_role_policy_attachment" "apprunner_role" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = data.aws_iam_policy.AWSAppRunnerServicePolicyForECRAccess.arn
}

resource "aws_apprunner_service" "private_ecr_example" {
  count = var.should_use_ecr ? 1 : 0
  service_name = "apprunner_ecr_${var.environment}"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }

    image_repository {
      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          DDB_AWS_REGION = var.region
          DDB_TABLE_NAME = module.dynamodb.restaurant_table_name
        }
      }

      image_identifier      = "${var.ecr_repo_url}:latest"
      image_repository_type = "ECR"
    }
  }

  instance_configuration {
    instance_role_arn = module.runtime_iam_role.iam_role_arn
  }
}
