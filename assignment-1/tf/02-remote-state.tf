resource "aws_s3_bucket" "state_bucket" {
  bucket        = "cc4-terraform-state-bucket"
  force_destroy = true

  tags = {
    Description = "S3 Remote State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "state_bucket_ownership" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "state_bucket_acl" {
  bucket = aws_s3_bucket.state_bucket.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.state_bucket_ownership
  ]
}

resource "aws_s3_bucket_object_lock_configuration" "state_bucket_object_lock_configuration" {
  bucket              = aws_s3_bucket.state_bucket.id
  object_lock_enabled = "Enabled"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform_state"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Description = "DynamoDB Remote State Lock Table"
  }
}
