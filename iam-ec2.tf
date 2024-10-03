
resource "aws_iam_instance_profile" "instance_profile" {
  name = "udisk-manager-instancerole"
  role = aws_iam_role.instancerole.name
}

data "aws_iam_policy_document" "assume_instancerole" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy_attachment" "instance-attach" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.instancerole.name]
  policy_arn = aws_iam_policy.instancepolicy.arn
}

resource "aws_iam_policy_attachment" "instancessm-attach" {
  name = "ssm-attachment"
  roles = [aws_iam_role.instancerole.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_policy" "instancepolicy" {
  name        = "udisk-instancepolicy"
  path        = "/"
  description = "Permissions required by appstream disksize increaser"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:GetRecords",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateTable"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.cache.arn
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = data.aws_s3_bucket.appsettings.arn
      },
      {
        Action = [
          "logs:PutLogEvents",
          "logs:ListMetrics"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.udisk-increase.arn
      }
    ]
  })
}

resource "aws_iam_role" "instancerole" {
  name               = "udisk-manager-instancerole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}