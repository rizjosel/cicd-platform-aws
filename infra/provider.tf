terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "my-tf-test-bucket-100524"
    key          = "eks/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true 
    profile      = "personal" 
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "personal"
}
