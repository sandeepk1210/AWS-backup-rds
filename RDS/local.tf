# Define common tags in a locals block
locals {
  common_tags = {
    Environment = "Development"
    Owner       = "Sandeep-Kumar"
    Project     = "Application-RDS"
  }
}

# Decode the secret JSON to retrieve the password
locals {
  db_credentials = jsondecode(resource.aws_secretsmanager_secret_version.rds_password_secret_version.secret_string)
}
