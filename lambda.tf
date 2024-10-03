

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "appstreamdiskincreaser" {
  filename      = "lambda_function_payload.zip"
  function_name = "appstream-apssettingsdisk-increaser"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  timeout = 60

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      BUCKET               = data.aws_s3_bucket.appsettings.id,
      PREFIX               = var.appstream_app_settings_bucket_prefix,
      BATCH_SIZE           = var.batch_size,
      TABLE                = aws_dynamodb_table.cache.name
      SSM_DOCUMENT         = aws_ssm_document.foo.name
      SSM_DOCUMENT_VERSION = aws_ssm_document.foo.latest_version
      EC2_INSTANCE         = aws_instance.web.id
      LOGGROUPNAME         = aws_cloudwatch_log_group.udisk-increase.name
    }
  }
}