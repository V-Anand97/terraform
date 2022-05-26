# provider "aws" {
#   region = "us-east-1"
#   //version = "~> 2.46"
# }

provider "aws" {
  region     = "us-east-1"
 # access_key = "ENTER-YOUR-ACCESS-KEY-HERE"
 # secret_key = "ENTER-YOUR-SECRET-KEY-HERE"
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "cld_devops_sg" {
  name = "cld_devops_sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80 #Open port 80 for Http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.sg_ip]
  }

  ingress {
    from_port   = 22 #Open port 22 for ssh
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.sg_ip]
  }

  ingress {
    from_port   = 8080 #Open port 8080 for Jenkins
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.sg_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.sg_ip]
  }

  tags = {
    name = "cld_devops__sg"
  }
}

//Deploy Server 
resource "aws_instance" "bare-ec2" {
  #ami                   = "ami-0c02fb55956c7d316"
  count                  = 3
  ami                    = data.aws_ami.amazon-2.id
  key_name               = "terraform"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cld_devops_sg.id]


  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.aws_key_pair)
    #private_key = file("D:/terraform/new_working_terraform/terraform.pem")
    #private_key = file("/Users/anandvaidyanathan/Documents/terraform/bare ec2/terraform.pem")


  }
 
  tags = {
    Name = "${element(var.instance_tags, count.index)}"
  }
}

output "bare-ec2-ip" {
  description = "Outputs the public ip of the instances"
  value = aws_instance.bare-ec2[*].public_ip
  
  
}

