

resource "aws_s3_bucket" "ojoo-bucket-2" {
  bucket = "ojoo-2"

  tags = {
    Name = "ojoo"
  }
}

resource "aws_s3_bucket_versioning" "versioning_ojoo-2" {
  bucket = aws_s3_bucket.ojoo-bucket-2.id
  versioning_configuration {
    status = "Disabled"
  }
}

# db table #
resource "aws_dynamodb_table" "website_dynamodb_table" {
  name           = "website"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "websiteID"

  attribute {
    name = "websiteID"
    type = "S"
  }

  tags = {
    Name = "website_DB_table"
  }
}