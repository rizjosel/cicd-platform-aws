
resource "aws_s3_bucket" "tf_state_s3" {
  bucket = "my-tf-test-bucket-100524"

  tags = {
    Name = "Terraform State"
  }
}

resource "aws_s3_bucket_versioning" "versioning_tf_state" {
  bucket = aws_s3_bucket.tf_state_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

