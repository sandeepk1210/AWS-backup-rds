output "rds_password" {
  description = "The generated RDS password"
  value       = random_password.rds_password.result
  sensitive   = true
}

output "rds_password_secret_arn" {
  description = "ARN of the RDS password secret stored in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.rds_password_secret.arn
}

output "rds_password_secret_version_id" {
  description = "Version ID of the RDS password secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret_version.rds_password_secret_version.version_id
}

output "rds_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "rds_instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.this.identifier
}

output "db_parameter_group_name" {
  description = "Name of the DB parameter group"
  value       = aws_db_parameter_group.db_parameter_group.name
}
