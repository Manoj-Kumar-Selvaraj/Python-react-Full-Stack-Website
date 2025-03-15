# Createing the Group

resource "aws_iam_group" "factory_outlet_db_developer_group" {
  name = var.group_name
}


# Creating the user with tag values

resource "aws_iam_user" "factory_outlet_db_developer" {
  name = var.user_name
  tags = {
    "Department" = "Backend",
    "Project" = "FactoryOutlet"
  }
}


# Attaching the user to Group

resource "aws_iam_user_group_membership" "factory_outlet_db_developer1_to_group" {
  user  = aws_iam_user.factory_outlet_db_developer.name
  groups  = [aws_iam_group.factory_outlet_db_developer_group.name]
}

# Granting Console Access to The user

resource "aws_iam_user_login_profile" "factory_outlet_db_developer_login" {
  user    = aws_iam_user.factory_outlet_db_developer.name
  # password = "Dummy" # This is managed automatically by AWS and its not allowed in terraform.
  password_reset_required = true  # Set to true if you want the user to change the password on first login
}

/*

When you create an IAM user in AWS, 
the system does not automatically send an email to the user with login details unless you explicitly configure it. 
AWS will not send any login credentials by default.
https://<account-id>.signin.aws.amazon.com/console.

*/

