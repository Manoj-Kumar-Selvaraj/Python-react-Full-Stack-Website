#!/bin/bash
echo "Installing dependencies..."
if command -v terraform &> /dev/null
then
    echo "Terraform is already installed. Version: $(terraform -v | head -n 1)"
else
    echo "Terraform is not installed. Installing now..."
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install terraform
    echo "Terraform version $(terraform -v | head -n 1) installed."
fi

echo "Terraform installation completed!"

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
sudo apt update
check_aws_cli
