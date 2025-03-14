#!/bin/bash

# Backup existing bashrc before modifying
cp ~/.bashrc ~/.bashrc.bak

# Remove AWS credentials from ~/.bashrc
sed -i '/export AWS_ACCESS_KEY_ID/d' ~/.bashrc
sed -i '/export AWS_SECRET_ACCESS_KEY/d' ~/.bashrc
sed -i '/export AWS_SESSION_TOKEN/d' ~/.bashrc

# Unset current session variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

echo "AWS credentials removed from ~/.bashrc and current session."
