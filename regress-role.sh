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
unset AWS_PROFILE


# Remove cached credentials
rm -rf ~/.aws/cli/cache

# Logout of AWS SSO (if used)
aws sso logout 2>/dev/null || echo "No active SSO session"

# Apply changes immediately
source ~/.bashrc

# Restart the shell to clear the session
exec bash

# Verify session is removed
aws sts get-caller-identity || echo "No active AWS session"
