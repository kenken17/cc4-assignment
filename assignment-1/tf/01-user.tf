provider "aws" {
  region  = "ap-southeast-1"
  profile = "cc4"
}

resource "aws_iam_user" "provisioner_user" {
  name = "provisioner_user"

  tags = {
    Description = "User to provision resources"
  }
}

resource "aws_iam_group" "provisioner_group" {
  name = "provisioner_group"
}

resource "aws_iam_policy" "provisioner_policy" {
  name        = "provisioner_policy"
  description = "provisioner policy"
  policy      = file("./policy/provision-policy.json")
}

resource "aws_iam_group_policy_attachment" "provisioner_attach" {
  group      = aws_iam_group.provisioner_group.name
  policy_arn = aws_iam_policy.provisioner_policy.arn
}

resource "aws_iam_user_group_membership" "provisioner_group_membership" {
  user = aws_iam_user.provisioner_user.name

  groups = [
    aws_iam_group.provisioner_group.name,
  ]
}
