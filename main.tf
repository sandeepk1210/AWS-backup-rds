resource "aws_db_instance" "prod" {
  // General Configurations
  engine            = "postgres"
  engine_version    = "14.7"
  instance_class    = "db.t3.medium"
  db_name           = "workdb"
  identifier        = "work-prod"

  //Authentication
  username          = "postgres"
  password          = "postgres"

  // Storage Configurations
  storage_type = "gp3"
  allocated_storage    = 20
  max_allocated_storage = 100

  #db_subnet_group_name = "my_database_subnet_group"
  #parameter_group_name = "default.mysql5.6"
  # final_snapshot_identifier = "ci-aurora-cluster-backup"

  // Networking and Security 
  publicly_accessible     = true

  // Monitoring and Performance Insight
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  monitoring_interval = "60"
  monitoring_role_arn = aws_iam_role.work-IAM-Role-RDS.arn
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.db_parameter_group.name
  apply_immediately    = true

  // Backup Configuration
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 5
  copy_tags_to_snapshot = true

  // Other Configurations
  auto_minor_version_upgrade = false
  deletion_protection = false
  skip_final_snapshot = true

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
    name  = "shared_preload_libraries"
    value = "auto_explain"
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

resource "aws_sns_topic" "topic" {
  name              = "iandp-team-topic"
  #kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "email-target" {
  count     = length(var.team-emails)
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.team-emails[count.index]
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name                = "${aws_db_instance.prod.identifier}-ecs-cluster-cpu-utilization-high"
  #alarm_name = "work-challenge-cluster-cpu-utilization-high"
  alarm_description         = "Scale up if CPU utilization is above ${var.cpu_utilization_high_threshold_percent} for ${var.cpu_utilization_high_period_seconds} seconds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period                    = var.cpu_utilization_high_period_seconds
  statistic                 = var.cpu_utilization_high_statistic
  threshold                 = var.cpu_utilization_high_threshold_percent
  alarm_actions = [aws_sns_topic.topic.arn]
  #insufficient_data_actions = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.prod.identifier
  }
}


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${aws_db_instance.prod.identifier}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "height": 6,
        "width": 24,
        "y": 0,
        "x": 0,
        "type": "log",
        "properties": {
            "query": "SOURCE '/aws/rds/instance/${aws_db_instance.prod.identifier}/postgresql' | filter @message like /execute/\n|parse @message ‘* * *@* duration: * *: *’ as Date,Time,session,session2,Query_time,query_type,Query\n|parse session ‘*:*:*’ as c1,Client_ip,User_name\n|parse session2 ‘*:*:*:’ as DB_name,c5,c6\n|display Date,Time,User_name,DB_name,Query_time/1000 as Query_time_sec,Query\n|sort Query_time_sec desc\n| limit 20",
            "region": "us-east-1",
            "stacked": false,
            "view": "table",
            "title": "Top 20 Slow Queries"
        }
      },
      {
        "type": "log",
        "x": 0,
        "y": 6,
        "width": 24,
        "height": 6,
        "properties": {
            "query": "SOURCE '/aws/rds/instance/${aws_db_instance.prod.identifier}/postgresql' | filter @message like /execute/\n| parse @message ‘* * *@* duration: * *: *’ as \nDate,Time,session,session2,Query_time,query_type,Query\n| parse session ‘*:*:*’ as c1,Client_ip,User_name\n| parse session2 ‘*:*:*:’ as DB_name,c5,c6\n| display Date,Time,User_name,DB_name,Query_time/1000 as \nQuery_time_sec,Query\n| sort Query_time_sec desc\n| limit 20",
            "region": "us-east-1",
            "stacked": false,
            "title": "Execution Plans for Slow Queries",
            "view": "table"
        }
      },
      {
        "type": "log",
        "x": 0,
        "y": 12,
        "width": 24,
        "height": 6,
        "properties": {
            "query": "SOURCE '/aws/rds/instance/${aws_db_instance.prod.identifier}/postgresql' | filter @message like /ERROR/\n| display @message",
            "region": "us-east-1",
            "stacked": false,
            "view": "table",
            "title": "Error log"
        }
      },
      {
        "type": "log",
        "x": 0,
        "y": 18,
        "width": 24,
        "height": 6,
        "properties": {
            "query": "SOURCE '/aws/rds/instance/${aws_db_instance.prod.identifier}/postgresql' | filter @message  like /automatic/\n| display @message",
            "region": "us-east-1",
            "title": "Auto-vacuum & Auto-analyze",
            "view": "table"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 24,
        "width": 6,
        "height": 6,
        "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
                [ "AWS/RDS", "DBLoad", "DBInstanceIdentifier", "climate-prod" ],
                [ ".", "DBLoadCPU", ".", "." ],
                [ ".", "DBLoadNonCPU", ".", "." ]
            ],
            "region": "us-east-1"
        }
      },
      {
        "type": "explorer",
        "x": 0,
        "y": 30,
        "width": 24,
        "height": 15,
        "properties": {
            "metrics": [
                {
                    "metricName": "CPUUtilization",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "DatabaseConnections",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Sum"
                },
                {
                    "metricName": "FreeStorageSpace",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "FreeableMemory",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "ReadLatency",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "ReadThroughput",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "ReadIOPS",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "WriteLatency",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "WriteThroughput",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                },
                {
                    "metricName": "WriteIOPS",
                    "resourceType": "AWS::RDS::DBInstance",
                    "stat": "Average"
                }
            ],
            "labels": [
                {
                    "key": "Name",
                    "value": "work-DB"
                }
            ],
            "widgetOptions": {
                "legend": {
                    "position": "bottom"
                },
                "view": "timeSeries",
                "stacked": false,
                "rowsPerPage": 50,
                "widgetsPerRow": 2
            },
            "period": 300,
            "splitBy": "",
            "region": "us-east-1"
        }
      }
    ]
  })
}