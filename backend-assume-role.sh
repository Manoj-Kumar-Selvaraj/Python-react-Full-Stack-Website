#!/bin/bash

# Unset any existing AWS credentials
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Assume the role and capture the output
ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "arn:aws:iam::039612868338:role/FactoryOutlet-Front-End-Root-Role" --role-session-name "USERCREATIONNOTIFICATIONS")

# Parse credentials
AWS_ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

# Append credentials to ~/.bashrc for persistence
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> ~/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> ~/.bashrc
echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> ~/.bashrc

# Apply changes immediately
source ~/.bashrc

# Verify the assumed role
aws sts get-caller-identity
