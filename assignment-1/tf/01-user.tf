provider "aws" {
  region  = "ap-southeast-1"
  profile = "cc4"
}

resource "aws_iam_user" "provisioner-user" {
  name = "provisioner-user"
  tags = {
    Description = "User to provision resources"
  }
}

resource "aws_iam_group" "provisioner-group" {
  name = "provisioner-group"
}

resource "aws_iam_policy" "provisioner-policy" {
  name        = "provisioner-policy"
  description = "provisioner policy"
  policy      = file("./policy/provision-policy.json")
}

resource "aws_iam_group_policy_attachment" "provisioner-attach" {
  group      = aws_iam_group.provisioner-group.name
  policy_arn = aws_iam_policy.provisioner-policy.arn
}

resource "aws_iam_user_group_membership" "provisioner-group-membership" {
  user = aws_iam_user.provisioner-user.name

  groups = [
    aws_iam_group.provisioner-group.name,
  ]
}
