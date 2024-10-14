#!/bin/bash
chmod +x setup.sh
if [ -d "/workspaces/Python-react-Full-Stack-Website/aws" ]; then    :
else
    cd /workspaces/Python-react-Full-Stack-Website/
    mkdir aws
fi
check_aws_cli() {
    # -v checks for command aws and returns true if found, can be used for all like git etc
    if command -v aws > /dev/null 2>&1; then
        echo "AWS CLI is installed."
        echo "Version: $(aws --version)"
    else
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        cd /workspaces/Python-react-Full-Stack-Website/aws
        echo "AWS INSTALLATION SUCCESSFUL"
    fi
};

# check_aws_cli