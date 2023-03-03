terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-0987654321"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}