terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "cloudn-monitoring-instance"
    key    = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.profile
}
