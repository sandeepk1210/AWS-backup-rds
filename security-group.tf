resource "aws_security_group" "allow_rds" {
  name        = "allow_rds"
  description = "Allow RDS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "PostgreSQL connect from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_rds"
  }
}
