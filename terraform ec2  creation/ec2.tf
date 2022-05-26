 provider "aws" {
  region = "us-east-1"
   //version = "~> 2.46"
}
/*
provider "aws" {
  region     = "us-east-1"
  access_key = "ENTER-YOUR-ACCESS-KEY-HERE"
  secret_key = "ENTER-YOUR-SECRET-KEY-HERE"
}
*/
#
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "cld_devops_sg" {
  name = "cld_devops_sg"
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

resource "aws_instance" "main-ec2" {
  #ami                   = "ami-0c02fb55956c7d316"
  count                  = 1
  ami                    = data.aws_ami.amazon-2.id
  key_name               = "terraform"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cld_devops_sg.id]
  user_data              = <<EOF
    #!/bin/bash
    sudo amazon-linux-extras install -y java-openjdk11
    sudo wget -O /etc/yum.repos.d/jenkins.repo \https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo systemctl status jenkins
    sudo yum install -y maven
    curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
    sudo yum install -y nodejs
    sudo yum install -y docker
    
	EOF

  //subnet_id              = "subnet-3f7b2563"
  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    # private_key = file(var.aws_key_pair)
    private_key = file("D:/terraform/new_working_terraform/terraform.pem")


  }
  tags = {
    Name = "main-ec2"
  }
}
//Deploy Server 
resource "aws_instance" "deploy-ec2" {
  #ami                   = "ami-0c02fb55956c7d316"
  count                  = 1
  ami                    = data.aws_ami.amazon-2.id
  key_name               = "terraform"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cld_devops_sg.id]


  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    # private_key = file(var.aws_key_pair)
    private_key = file("D:/terraform/new_working_terraform/terraform.pem")


  }
  tags = {
    Name = "deploy-ec2"
  }
}



