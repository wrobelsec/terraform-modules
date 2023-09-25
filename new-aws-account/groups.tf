# Create the console group
resource "aws_iam_group" "console_group" {
  name = local.console_group_name
}

# Create the admin group
resource "aws_iam_group" "admin_group" {
  name = local.admin_group_name
}

# Assign the admin policy to the admin group
resource "aws_iam_group_policy_attachment" "admin_group_policy" {
  group      = aws_iam_group.admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}