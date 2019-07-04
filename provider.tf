terraform {
  required_version = "0.12.3"
}

provider "aws" {
  region  = "us-east-1"
}

provider "aws" {
  alias   = "eu"
  region  = "eu-west-1"
}

