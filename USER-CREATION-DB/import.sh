#!/usr/bin/env bash

# Ensure Terraform is initialized
terraform init

# Function to check and import a resource if it's not managed by Terraform
import_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local aws_name="$3"

    echo "🔍 Checking $resource_type.$resource_name..."
    
    if terraform state list | grep -q "$resource_type.$resource_name"; then
        echo "✅ $resource_type.$resource_name is already managed by Terraform."
    else
        echo "🔄 Importing $resource_type.$resource_name..."
        terraform import "$resource_type.$resource_name" "$aws_name" && echo "✅ Successfully imported $resource_type.$resource_name" || echo "❌ Failed to import $resource_type.$resource_name"
    fi
}

# Import IAM Group
import_resource "module.IAM.module.RESOURCES.aws_iam_group" "factory_outlet_db_developer_group" "FactoryOutletDBDevelopers"

# Import IAM User
import_resource "module.IAM.module.RESOURCES.aws_iam_user" "factory_outlet_db_developer" "FactoryOutletDBDeveloper1"

# Import IAM User Login Profile (to avoid creation errors)
import_resource "module.IAM.module.RESOURCES.aws_iam_user_login_profile" "factory_outlet_db_developer_login" "FactoryOutletDBDeveloper1"

echo "🎉 All necessary resources have been imported!"
