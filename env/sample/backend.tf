provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [533266996794]
}
terraform {
  backend "s3" {
    bucket = "tac0x2a-tf-backend"
    key    = "backend"
    region = "us-east-1"
  }
}
