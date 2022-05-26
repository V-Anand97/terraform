resource "aws_eip" "attributeeip" {
  vpc      = true
}

output "eip" {
  value = aws_eip.attributeeip.address
}


resource "aws_instance" "attributesec2" {
    ami = "ami-0022f774911c1d690"
    instance_type = "t2.micro"
  
}

resource "aws_eip_association" "eip_assoc" {
    instance_id   = aws_instance.attributesec2.id
    allocation_id = aws_eip.attributeeip.id
  
}

resource "aws_security_group" "allow_tls" {
  name        = "attributes-security-group"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.attributeeip.public_ip}/32"]

#    cidr_blocks = [aws_eip.lb.public_ip/32]
  }
} 
/*
resource "aws_s3_bucket" "mys3" {
  bucket = "anand-attribute-demo-0091"
}

output "mys3bucket" {
  value = aws_s3_bucket.mys3.bucket_domain_name
}

output "mys3bucketid" {
  value = aws_s3_bucket.mys3
}


*/

