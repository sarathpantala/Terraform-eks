provider "aws" {
  version = ">= 1.47.0"
  region  = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "sandbox-eks-tf-state"
    key    = "terraform-state"
    region = "us-east-1"
  }
}
