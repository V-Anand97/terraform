terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}


resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "TF-Ansible-worker-nodes-SG" {
  name = "TF-Ansible-worker-nodes-SG"
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
    name = "TF-Ansible-worker-nodes-SG"
  }
}

resource "aws_instance" "ansible_worker_nodes" {
  #ami                   = "ami-0c02fb55956c7d316"
  count                  = 3
  ami                    = data.aws_ami.amazon-2.id
  key_name               = "terraform"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.TF-Ansible-worker-nodes-SG.id]
  user_data              = <<EOF
    #!/bin/bash
    sudo su -
    yum update -y
    yum install python3 -y
    yum install pip -y
    pip install ansible
	EOF


  //subnet_id              = "subnet-3f7b2563"
  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    # private_key = file(var.aws_key_pair)
    # private_key = file("D:/terraform/new_working_terraform/terraform.pem")
    private_key = file("/Users/anandvaidyanathan/Documents/terraform/ansible worker nodes/terraform.pem")

  }
  tags = {
    Name = element(var.aws_instance_tags, count.index)
  }
}

output "instance_ip" {
  description = "Public IPs of the ansible worker nodes instances"
  value       = aws_instance.ansible_worker_nodes[*].public_ip
}
