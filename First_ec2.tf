/* intimating the provider information */
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.39.0"
    }
  }
}

/* Authenticating the provider */
provider "aws" {
  region = "us-east-1"
  access_key = "xxxxx"
  secret_key = "xxxxxx"

}

# declaring the resource required linux instance AMI
/*
resource "aws_instance" "terraform-instance" {
  ami = "ami-07a3e3eda401f8caa" #us-west-2
  instance_type = "t2.micro"
}
*/
/* declaring the resource required windows instance AMI*/
resource "aws_instance" "terraform_windows_instance" {
  ami = "ami-0f93c815788872c5d" #us-west-1
  instance_type = "t2.micro"
tags = {
  Name = "terraform-win"
}
}
