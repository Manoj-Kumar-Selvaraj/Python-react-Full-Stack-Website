resource "aws_sns_topic" "user_creation_topic" {
  name = "user-creation-notifications"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
}

resource "aws_sns_topic_subscription" "user_creation_email_subscription" {
  depends_on = [aws_sns_topic.user_creation_topic]
  topic_arn = aws_sns_topic.user_creation_topic.arn
  protocol  = "email"
  endpoint  = "ss.mano1998@gmail.com"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
 } 
}


