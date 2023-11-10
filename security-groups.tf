resource "aws_security_group" "monitoring_instance_sg" {
  name        = "Monitoring Instance Security Group"
  description = "Prometheus / Grafana / SSH allow traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.security_ingress
    iterator = ing
    content {
      from_port   = ing.value["from_port"]
      to_port     = ing.value["to_port"]
      protocol    = ing.value["protocol"]
      cidr_blocks = ing.value["cidr_block"]
    }
  }

  dynamic "egress" {
    for_each = var.security_egress
    iterator = eng
    content {
      from_port   = eng.value["from_port"]
      to_port     = eng.value["to_port"]
      protocol    = eng.value["protocol"]
      cidr_blocks = eng.value["cidr_block"]
    }
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "EFS Security Group"
  description = "Allow traffic from inside vpc resources only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
