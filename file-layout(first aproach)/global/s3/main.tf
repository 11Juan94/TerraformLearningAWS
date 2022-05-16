provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
      bucket = "private-terraform-state-test"
      key = "global/s3/terraform.tfstate"
      region = "us-east-2"

      dynamodb_table = "private-terraform-locks-test"
      encrypt = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "private-terraform-state-test"

    # Prevent accidental deletion of this S3 bucket
    lifecycle {
      prevent_destroy = true
    }
}

# Make bucket private
resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "terraform_state_ver" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default on S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_sse" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "private-terraform-locks-test"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}