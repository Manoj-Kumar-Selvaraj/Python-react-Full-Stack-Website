# EventBridge Rule
resource "aws_cloudwatch_event_rule" "usercreationnotificationrule" {
  name        = "iam-user-created-rule"
  description = "Trigger Lambda when a new IAM user is created"
  event_pattern = jsonencode({
    "source": ["aws.iam"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["iam.amazonaws.com"],
      "eventName": ["CreateUser"]
    }
  })
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "example" {
  rule      = aws_cloudwatch_event_rule.example.name
  target_id = "lambda-function"
  arn       = var.cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_arn
}

# Permissions for EventBridge to Invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.usercreationnotificationrule.arn
}