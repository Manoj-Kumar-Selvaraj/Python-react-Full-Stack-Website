#!/bin/bash

# Unset any existing AWS credentials
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Assume the role and capture the output
ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "arn:aws:iam::039612868338:role/FactoryOutlet-Front-End-Root-Role" --role-session-name "USERCREATIONNOTIFICATIONS")

# Parse and export the credentials
export AWS_ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

# Verify the assumed role identity
aws sts get-caller-identity
