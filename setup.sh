#!/bin/bash
chmod +x setup.sh
if [ -d "/workspaces/Python-react-Full-Stack-Website/aws" ]; then
    pass
else
    cd /workspaces/Python-react-Full-Stack-Website/
    mkdir aws
fi
check_aws_cli() {
    if command -v aws > /dev/null 2>&1; then
        echo "AWS CLI is installed."
        echo "Version: $(aws --version)"
    else
        
    fi
}
