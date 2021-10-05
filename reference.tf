#configuring the provider version
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.39.0"
    }
  }
}
/*

#Authenticating the provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4AHR7SN4I4MO3SPF"
  secret_key = "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"

}
*/
#Creating an Ec2 instance
resource "aws_instance" "linux-tf" {
  ami = "ami-0aeeebd8d2ab47354"
  instance_type = "t2.micro"



}

#Creating an Elastic IP
resource "aws_eip" "new-eip" {
  vpc = true

}

#Associate the Elastic IP
resource "aws_eip_association" "eip_assocc" {
  instance_id = aws_instance.linux-tf.id
  allocation_id = aws_eip.new-eip.id                              #Name of the EIP

}

#Creatring a nee security group

resource "aws_security_group" "linux-tf" {
  name = "linux-tf_allow"
  description = "linux-tf-allowing the inboud rules"


ingress {
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["${aws_eip.new-eip.public_ip}/32"]
  #cidr_blocks = [aws_eip.new-eip.public_ip/28]
}
}
