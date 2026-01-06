terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "terraform-project-kripal"
    key   = "terraform/state/terraform-aws-s3-static-site/terraform.tfstate"
    use_lockfile = true
    encrypt = true
    region = "us-east-1"
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
