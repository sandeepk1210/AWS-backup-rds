resource "aws_db_instance" "prod" {
  // General Configurations
  engine         = "postgres"
  engine_version = "14.8"
  instance_class = "db.t3.small"
  db_name        = "workdb"
  identifier     = "work-prod"

  //Authentication
  username = "postgres"
  password = "postgres"

  // Storage Configurations
  storage_type          = "gp3"
  allocated_storage     = 20
  max_allocated_storage = 100

  #db_subnet_group_name = "my_database_subnet_group"
  #parameter_group_name = "default.mysql5.6"
  # final_snapshot_identifier = "ci-aurora-cluster-backup"

  // Networking and Security 
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.allow_rds.id]

  // Monitoring and Performance Insight
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval             = "60"
  monitoring_role_arn             = aws_iam_role.work-IAM-Role-RDS.arn
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.db_parameter_group.name
  apply_immediately    = true

  // Backup Configuration
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 5
  copy_tags_to_snapshot   = true

  // Other Configurations
  auto_minor_version_upgrade = false
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = {
    Name = "work-DB"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "workdb-postgres14"
  family = "postgres14"

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
  source_ids  = [aws_db_instance.prod.identifier]

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
#   db_instance_identifier = aws_db_instance.prod.id
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
#   //snapshot_identifier = "rds-snapshot-workdb-xjuxgg14orun"
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



