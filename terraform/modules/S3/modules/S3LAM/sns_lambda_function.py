import boto3
import json

# Initialize the SNS client
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    # Retrieve information passed to the Lambda function as payload
    user = event['user']         # IAM user created
    topic_arn = event['topic_arn'] # ARN of the SNS topic
    
    message = f"IAM user '{user}' has been created. Initial password setup is pending in the AWS Console by the Root User."
    
    # Publish the message to the SNS topic
    sns_client.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject="IAM User Creation Notification"
    )
    
    # Return a response for debugging/logging
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Notification sent successfully"})
    }
