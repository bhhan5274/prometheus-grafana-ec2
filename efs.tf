resource "aws_efs_file_system" "efs_file_system" {
  creation_token   = "monitoring-instance"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "monitoring-instance-efs"
  }
}

resource "aws_efs_mount_target" "mount_target1" {
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "mount_target2" {
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = module.vpc.public_subnets[1]
  security_groups = [aws_security_group.efs_sg.id]
}
