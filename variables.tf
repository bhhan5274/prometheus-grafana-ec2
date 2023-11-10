variable "aws_region" {
  type = string
}

variable "profile" {
  type = string
}

variable "security_ingress" {
  type = map(object({ from_port = number, to_port = number, protocol = string, cidr_block = list(string) }))
}

variable "security_egress" {
  type = map(object({ from_port = number, to_port = number, protocol = string, cidr_block = list(string) }))
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_key_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "efs_mount_point" {
  type = string
}
