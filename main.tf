resource "random_id" "bucket_suffix" {
  byte_length = 4
}
resource "aws_s3_bucket" "example" {
  bucket = "terraform-foundations-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "terraform-foundations-bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}