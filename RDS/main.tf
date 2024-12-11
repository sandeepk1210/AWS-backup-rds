# Generate Random Password
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+<>?"
}

# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "rds_password_secret" {
  name        = "rds-db-password"
  description = "RDS database password stored in AWS Secrets Manager"
  tags        = local.common_tags
}

# AWS Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "rds_password_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.rds_password.result
  })
}

resource "aws_db_instance" "this" {
  // General Configurations
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name        = var.db_name
  identifier     = "app-db"

  //Authentication
  username = local.db_credentials["username"]
  password = local.db_credentials["password"]

  // Storage Configurations
  storage_type          = "gp3"
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true

  // Networking and Security 
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.allow_rds.id]

  // Monitoring and Performance Insight
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval             = "60"
  monitoring_role_arn             = aws_iam_role.monitoring-rds-iam-role.arn
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.db_parameter_group.name
  apply_immediately    = true

  // Backup Configuration
  // The maintenance window is the timeframe during which AWS may perform system maintenance, 
  //  such as updates or patching for your RDS instance. 
  //  This can result in a short downtime, so careful planning is essential.
  // Duration: AWS uses the minimum time necessary, but you should allocate 3 hours 
  //  to ensure sufficient time for updates (default is 30 minutes to 3 hours).
  maintenance_window = var.maintenance_window
  // The backup window is the timeframe during which AWS RDS creates automated backups of your database. 
  //  While backups are usually transparent, they can impact performance due to increased I/O.
  // Duration: AWS recommends a 30-minute to 2-hour window, depending on your database size and workload.
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot   = true

  // Other Configurations
  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = merge(local.common_tags, {
    "AWSEBRBackup" = "DS14-12AM"
  })
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "appdb-postgres${var.engine}"
  family = "postgres${var.engine}"

  parameter {
    name  = "log_temp_files"
    value = "1024"
  }

  parameter {
    name  = "Log_min_messages"
    value = "error"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "rds.force_autovacuum_logging_level"
    value = "log"
  }

  parameter {
    name  = "log_autovacuum_min_duration"
    value = "1000"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "auto_explain"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "auto_explain.log_min_duration"
    value = "1000"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_event_subscription" "default" {
  name      = "rds-event-sub"
  sns_topic = aws_sns_topic.topic.arn

  /* The type of source that will be generating the events. 
    Valid options are db-instance, db-security-group, db-parameter-group, 
                      db-snapshot, db-cluster or db-cluster-snapshot.
   */
  source_type = "db-instance"
  source_ids  = [aws_db_instance.this.identifier]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration",
  ]
}

# data "aws_db_snapshot" "lawork_prod_snapshot" {
#   db_instance_identifier = aws_db_instance.this.id
#   most_recent            = true
# }

# Use the lawork production snapshot to create a dev instance.
# resource "aws_db_instance" "dev" {
#   instance_class      = "db.t3.small"
#   identifier          = "work-dev"
#   allocated_storage   = 50
#   engine              = "postgres"
#   engine_version      = "14.6"
#   publicly_accessible = true
#   //db_name                = "mydbdev"
#   //snapshot_identifier = "rds-snapshot-appdb-xjuxgg14orun"
#   snapshot_identifier     = data.aws_db_snapshot.lawork_prod_snapshot.id
#   maintenance_window      = "Mon:00:00-Mon:03:00"
#   backup_window           = "03:00-06:00"
#   skip_final_snapshot     = true
#   backup_retention_period = 5

#   lifecycle {
#     ignore_changes = [snapshot_identifier]
#   }
# }

# resource "aws_db_instance" "dev-read" {
#   identifier          = "dev-read"
#   replicate_source_db = aws_db_instance.dev.identifier ## refer to the master instance
#   #db_name                   = "devreaddb"
#   instance_class    = "db.t3.small"
#   allocated_storage = 50
#   #engine                 = "postgres"
#   #engine_version         = "12.5"
#   skip_final_snapshot = true
#   publicly_accessible = true
#   #vpc_security_group_ids = [aws_security_group.uddin.id]
#   # Username and password must not be set for replicas
#   # username = ""
#   # password = ""
#   # disable backups to create DB faster
#   backup_retention_period = 5
# }



