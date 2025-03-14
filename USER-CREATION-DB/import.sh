#!/usr/bin/env bash

# Ensure Terraform is initialized
terraform init

# Function to import a resource if it exists
import_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local aws_name="$3"

    # Check if Terraform already manages this resource
    if terraform state list | grep -q "$resource_type.$resource_name"; then
        echo "✅ $resource_type.$resource_name is already managed by Terraform."
    else
        echo "🔄 Importing $resource_type.$resource_name..."
        terraform import "$resource_type.$resource_name" "$aws_name" || echo "❌ Failed to import $resource_type.$resource_name"
    fi
}

# Import IAM User
import_resource "aws_iam_user" "factory_outlet_db_developer" "FactoryOutletDBDeveloper1"

# Import IAM Group
import_resource "aws_iam_group" "factory_outlet_db_developer_group" "FactoryOutletDBDevelopers"
