data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "ec2.amazonaws.com", "ssm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "policy-lambda-attach" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.policy.arn
}


resource "aws_iam_policy" "policy" {
  name        = "lambda_policy"
  path        = "/"
  description = "Permissions required by appstream disksize increaser"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:GetRecords"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.cache.arn
      },
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = data.aws_s3_bucket.appsettings.arn
      },
      {
        Action = [
          "logs:PutLogEvents",
          "logs:ListMetrics",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.udisk-increase.arn
      }
    ]
  })
}