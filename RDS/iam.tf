# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "monitoring-rds-iam-role" {
  name = "monitoring-rds-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "monitoring-rds-iam-role"
  }
}

# Attach the managed policy
resource "aws_iam_role_policy_attachment" "monitoring_rds_policy" {
  role       = aws_iam_role.monitoring-rds-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}