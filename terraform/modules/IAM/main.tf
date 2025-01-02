# Createing the Group

resource "aws_iam_group" "factory_outlet_frontend_developer_group" {
  name = "FactoryOutletFrontEndDevelopers"
}

# Creating the user with tag values

resource "aws_iam_user" "factory_outlet_frontend_developer1" {
  name = "FactoryOutletFrontEndDeveloper1"
  tags = {
    "Technologies_And_Services" = ["React", "Terraform", "AWS S3", "AWS CodePipeline", "AWS CodeBuild", "AWS SecretsManager","AWS EC2", "AWS Route53", "AWS CloudFront", "AWS VPC", "AWS CLoudWatch", "AWS SNS", "AWS EFS", "AWS EBS", "AWS STSVPN", "AWS Console"]
  }
}

# Attaching the user to Group

resource "aws_iam_user_group_membership" "factory_outlet_frontend_developer1_to_group" {
  user  = aws_iam_user.factory_outlet_frontend_developer1.name
  groups  = [aws_iam_group.factory_outlet_frontend_developer_group.name]
}

# Granting Console Access to The user

resource "aws_iam_user_login_profile" "factory_outlet_frontend_developer1_login" {
  user    = aws_iam_user.factory_outlet_frontend_developer1.name
  # password = "Dummy" # This is managed automatically by AWS and its not allowed in terraform.
  password_reset_required = true  # Set to true if you want the user to change the password on first login
}

/*

When you create an IAM user in AWS, 
the system does not automatically send an email to the user with login details unless you explicitly configure it. 
AWS will not send any login credentials by default.
https://<account-id>.signin.aws.amazon.com/console.

*/

