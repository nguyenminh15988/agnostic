resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow traffic to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow database access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-security-group"
    Environment = var.environment
  }
}

# Outputs
output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}
