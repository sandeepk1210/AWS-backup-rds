resource "aws_sns_topic" "topic" {
  name = "email-team-topic"
  #kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "email-target" {
  count     = length(var.team-emails)
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.team-emails[count.index]
}
