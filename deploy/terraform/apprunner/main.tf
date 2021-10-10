terraform {
  backend "s3" {
    key = "terraform/environment/votingapp/apprunner.tfstate"
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
  table_suffix = "master"
}

module "runtime_iam_role" {
  source = "./iam"
  dynamodb_table_arn = module.dynamodb.restaurant_table_arn
}

resource "aws_apprunner_service" "code_example" {
  service_name = "apprunner_code_example"

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
        value = "master"
      }
    }
  }

  instance_configuration {
    instance_role_arn = module.runtime_iam_role.iam_role_arn
  }
}
