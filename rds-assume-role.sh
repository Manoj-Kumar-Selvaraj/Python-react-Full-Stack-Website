#!/bin/bash

# Unset any existing AWS credentials
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Remove AWS credentials from ~/.bashrc
sed -i '/export AWS_ACCESS_KEY_ID/d' ~/.bashrc
sed -i '/export AWS_SECRET_ACCESS_KEY/d' ~/.bashrc
sed -i '/export AWS_SESSION_TOKEN/d' ~/.bashrc

# Assume the role and capture the output
ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "arn:aws:iam::039612868338:role/FactoryOutletDBRootRole" --role-session-name "USERCREATION")

# Check if assume-role command was successful
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to assume role"
    exit 1
fi

# Parse credentials
AWS_ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

# Ensure credentials were retrieved
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_SESSION_TOKEN" ]]; then
    echo "❌ Error: Unable to retrieve credentials"
    exit 1
fi

# Append credentials to ~/.bashrc
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> ~/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> ~/.bashrc
echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> ~/.bashrc
echo "✅ AWS Role Assumed & Credentials Updated!"

# Apply changes immediately
source ~/.bashrc

# Spawn a new shell to reflect changes immediately
exec bash

# Verify the assumed role
aws sts get-caller-identity
