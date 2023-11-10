resource "aws_instance" "monitoring_instance" {
  depends_on    = [aws_efs_mount_target.mount_target1, aws_efs_mount_target.mount_target2]
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]

  key_name        = var.instance_key_name
  security_groups = [aws_security_group.monitoring_instance_sg.id]

  user_data = base64encode(templatefile("${path.module}/monitoring-instance.tpl", {
    efs_mount_point = var.efs_mount_point
    file_system_id  = aws_efs_file_system.efs_file_system.id
  }))

  tags = {
    Name = "monitoring-instance"
  }
}

resource "aws_eip" "monitoring_instance_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_instance_assoc" {
  depends_on = [aws_instance.monitoring_instance, aws_eip.monitoring_instance_eip]

  instance_id   = aws_instance.monitoring_instance.id
  allocation_id = aws_eip.monitoring_instance_eip.id
}
