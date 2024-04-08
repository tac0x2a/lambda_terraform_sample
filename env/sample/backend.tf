provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "tac0x2a-tf-backend"
    key    = "backend"
    region = "us-east-1"
  }
}