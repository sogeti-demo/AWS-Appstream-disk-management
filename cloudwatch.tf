resource "aws_cloudwatch_log_group" "udisk-increase" {
  name              = "custom-appstream-appsettingsdisk-increase"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_metric_filter" "monitor" {
  name           = "udisk-increase-errors"
  pattern        = "Something went wrong processing user"
  log_group_name = aws_cloudwatch_log_group.udisk-increase.name

  metric_transformation {
    name      = "Errors"
    namespace = "appsettingsdisk"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "monitor" {
  alarm_name          = "udisk-increase-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "appsettingsdisk"
  period              = 120
  statistic           = "SampleCount"
  threshold           = 1
  alarm_description   = "This metric monitors errors in the appsettings increase mechanism"
  alarm_actions       = [aws_sns_topic.admin_updates.arn]

}