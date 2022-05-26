terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}

provider "aws" {
  # Configuration options

  region = "us-east-1"
}


resource "aws_instance" "myec2" {
  ami           = "ami-0022f774911c1d690"
  instance_type = "t2.micro"

}
