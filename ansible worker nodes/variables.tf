variable "aws_key_pair" {
  default = "D:\terraform\terraform.pem"
}

variable "aws_instance_tags" {
  type = list
  default = ["ansible_worker_node-1", "ansible_worker_node-2", "ansible_worker_node-3"]
  
}