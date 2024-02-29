resource "aws_s3_bucket" "state-bucket" {
  bucket = "cc4-terraform-state-bucket"
  tags = {
    Description = "S3 Remote State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "state-bucket-versioning" {
  bucket = aws_s3_bucket.state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "state-bucket-ownership" {
  bucket = aws_s3_bucket.state-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "state-bucket-acl" {
  bucket = aws_s3_bucket.state-bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.state-bucket-ownership]
}

resource "aws_s3_bucket_object_lock_configuration" "state-bucket-object-lock-configuration" {
  bucket              = aws_s3_bucket.state-bucket.id
  object_lock_enabled = "Enabled"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state-bucket-server-side-encryption-configuration" {
  bucket = aws_s3_bucket.state-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
  name           = "terraform_state"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Description" = "DynamoDB Remote State Lock Table"
  }
}
