# Terraform tfstate

### backend
```
resource "aws_s3_bucket"  "msobo_terraform" {
  bucket = "msobo-terraform"
  tags = {
    Name = "msobo-terraform"
  }
}

resource "aws_s3_bucket_versioning" "msobo_terraform" {
  bucket = aws_s3_bucket.msobo_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "msobo_terraform_state_lock1" {
  name = "msobo-terraform-state-lock"
  read_capacity = 2
  write_capacity = 1
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "msobo-terraform"
  }
}
```
