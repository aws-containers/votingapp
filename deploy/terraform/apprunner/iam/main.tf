data "aws_iam_policy_document" "apprunner_runtime" {
  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      var.dynamodb_table_arn,
    ]

    effect = "Allow"
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
        "tasks.apprunner.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "apprunner_role" {
  name = "apprunner_role"

  assume_role_policy = data.aws_iam_policy_document.apprunner_policy.json
  inline_policy {
    name = "access_dynamo_db"

    policy = data.aws_iam_policy_document.apprunner_runtime.json
  }
}
