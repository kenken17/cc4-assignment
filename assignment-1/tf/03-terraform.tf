terraform {
  backend "s3" {
    region         = "ap-southeast-1"
    profile        = "cc4"
    bucket         = "cc4-terraform-state-bucket"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform_state"
  }
}
