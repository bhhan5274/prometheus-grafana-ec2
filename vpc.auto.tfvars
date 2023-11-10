aws_region = "ap-northeast-2"
profile    = "bhhan"

security_ingress = {
  ssh = {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_block = ["0.0.0.0/0"]
  },
  grafana = {
    from_port  = 3000
    to_port    = 3000
    protocol   = "tcp"
    cidr_block = ["0.0.0.0/0"]
  },
  prometheus = {
    from_port  = 9090
    to_port    = 9090
    protocol   = "tcp"
    cidr_block = ["0.0.0.0/0"]
  }
}

security_egress = {
  all = {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = ["0.0.0.0/0"]
  }
}

ami               = "ami-0e01e66dacaf1454d"
instance_type     = "t2.micro"
instance_key_name = "bhhan-instance-key"
vpc_cidr          = "10.0.0.0/16"
efs_mount_point   = "efs"
