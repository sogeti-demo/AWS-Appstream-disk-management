resource "aws_scheduler_schedule" "example" {
  name       = "udisk-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.trigger_schedule

  schedule_expression_timezone = var.trigger_timezone

  target {
    arn      = aws_lambda_function.appstreamdiskincreaser.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}