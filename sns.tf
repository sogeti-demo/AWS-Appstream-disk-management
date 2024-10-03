resource "aws_sns_topic" "admin_updates" {
  name = "user-updates-topic"
}

resource "aws_sns_topic_subscription" "admin_updates_sqs_target" {
  for_each = var.notification_endpoints

  topic_arn = aws_sns_topic.admin_updates.arn
  protocol  = "email"
  endpoint  = each.value


}