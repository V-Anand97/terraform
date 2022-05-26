terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}


provider "aws" {
  region     = "us-east-1"

}


resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "TF-Docker-SG" {
  name = "TF-Docker-SG"
  //vpc_id = "vpc-c49ff1be"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80 #Open port 80 for Http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22 #Open port 22 for ssh
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080 #Open port 8080 for Jenkins
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "cld_devops__sg"
  }
}

resource "aws_instance" "Docker" {
  #ami                   = "ami-0c02fb55956c7d316"
  #count                  = 1
  ami                    = data.aws_ami.amazon-2.id
  key_name               = "terraform"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.TF-Docker-SG.id]
  user_data              = <<EOF
    #!/bin/bash 
    sudo su -
    sudo yum install -y docker
    systemctl start docker
    systemctl enable docker
    systemctl restart docker
	EOF


  //subnet_id              = "subnet-3f7b2563"
  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    # private_key = file(var.aws_key_pair)
    # private_key = file("D:/terraform/new_working_terraform/terraform.pem")
    private_key = file("/Users/anandvaidyanathan/Documents/terraform/docker/terraform.pem")

  }
  tags = {
    Name = "Docker"
  }
}

output "instance_ip" {
  description = "IP of the EC2 instance"
  value       = aws_instance.Docker.public_ip
}




