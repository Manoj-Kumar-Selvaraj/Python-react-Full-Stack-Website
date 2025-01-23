import boto3
import json
import logging
import os

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize the SNS client
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # Log the incoming event
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Retrieve information from the event
        print("Received event:", json.dumps(event, indent=2))  # Debugging purposes
    
        # Extract user details from the EventBridge event
        detail = event.get("detail", {})
        user = detail.get("requestParameters", {}).get("userName")
        topic_arn = os.getenv("SNS_TOPIC_ARN")
        
        if not user or not topic_arn:
            raise ValueError("Required keys 'user' and 'topic_arn' are missing in the event payload.")
        
        # Create the notification message
        message = f"IAM user '{user}' has been created. Initial password setup is pending in the AWS Console by the Root User."
        
        # Publish the message to the SNS topic
        sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject="IAM User Creation Notification"
        )
        
        # Return a success response
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Notification sent successfully"})
        }
    
    except Exception as e:
        # Log the error
        logger.error(f"Error occurred: {str(e)}")
        
        # Return an error response
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
