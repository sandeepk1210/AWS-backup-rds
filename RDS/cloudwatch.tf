resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name = "${aws_db_instance.this.identifier}-ecs-cluster-cpu-utilization-high"
  #alarm_name = "work-challenge-cluster-cpu-utilization-high"
  alarm_description   = "Scale up if CPU utilization is above ${var.cpu_utilization_high_threshold_percent} for ${var.cpu_utilization_high_period_seconds} seconds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_utilization_high_period_seconds
  statistic           = var.cpu_utilization_high_statistic
  threshold           = var.cpu_utilization_high_threshold_percent
  alarm_actions       = [aws_sns_topic.topic.arn]
  #insufficient_data_actions = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }
}


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${aws_db_instance.this.identifier}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "height" : 6,
        "width" : 24,
        "y" : 0,
        "x" : 0,
        "type" : "log",
        "properties" : {
          "query" : "SOURCE '/aws/rds/instance/${aws_db_instance.this.identifier}/postgresql' | filter @message like /execute/\n|parse @message ‘* * *@* duration: * *: *’ as Date,Time,session,session2,Query_time,query_type,Query\n|parse session ‘*:*:*’ as c1,Client_ip,User_name\n|parse session2 ‘*:*:*:’ as DB_name,c5,c6\n|display Date,Time,User_name,DB_name,Query_time/1000 as Query_time_sec,Query\n|sort Query_time_sec desc\n| limit 20",
          "region" : "us-east-1",
          "stacked" : false,
          "view" : "table",
          "title" : "Top 20 Slow Queries"
        }
      },
      {
        "type" : "log",
        "x" : 0,
        "y" : 6,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "query" : "SOURCE '/aws/rds/instance/${aws_db_instance.this.identifier}/postgresql' | filter @message like /execute/\n| parse @message ‘* * *@* duration: * *: *’ as \nDate,Time,session,session2,Query_time,query_type,Query\n| parse session ‘*:*:*’ as c1,Client_ip,User_name\n| parse session2 ‘*:*:*:’ as DB_name,c5,c6\n| display Date,Time,User_name,DB_name,Query_time/1000 as \nQuery_time_sec,Query\n| sort Query_time_sec desc\n| limit 20",
          "region" : "us-east-1",
          "stacked" : false,
          "title" : "Execution Plans for Slow Queries",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "x" : 0,
        "y" : 12,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "query" : "SOURCE '/aws/rds/instance/${aws_db_instance.this.identifier}/postgresql' | filter @message like /ERROR/\n| display @message",
          "region" : "us-east-1",
          "stacked" : false,
          "view" : "table",
          "title" : "Error log"
        }
      },
      {
        "type" : "log",
        "x" : 0,
        "y" : 18,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "query" : "SOURCE '/aws/rds/instance/${aws_db_instance.this.identifier}/postgresql' | filter @message  like /automatic/\n| display @message",
          "region" : "us-east-1",
          "title" : "Auto-vacuum & Auto-analyze",
          "view" : "table"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 24,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "DBLoad", "DBInstanceIdentifier", "climate-prod"],
            [".", "DBLoadCPU", ".", "."],
            [".", "DBLoadNonCPU", ".", "."]
          ],
          "region" : "us-east-1"
        }
      },
      {
        "type" : "explorer",
        "x" : 0,
        "y" : 30,
        "width" : 24,
        "height" : 15,
        "properties" : {
          "metrics" : [
            {
              "metricName" : "CPUUtilization",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "DatabaseConnections",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Sum"
            },
            {
              "metricName" : "FreeStorageSpace",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "FreeableMemory",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "ReadLatency",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "ReadThroughput",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "ReadIOPS",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "WriteLatency",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "WriteThroughput",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            },
            {
              "metricName" : "WriteIOPS",
              "resourceType" : "AWS::RDS::DBInstance",
              "stat" : "Average"
            }
          ],
          "labels" : [
            {
              "key" : "Name",
              "value" : "work-DB"
            }
          ],
          "widgetOptions" : {
            "legend" : {
              "position" : "bottom"
            },
            "view" : "timeSeries",
            "stacked" : false,
            "rowsPerPage" : 50,
            "widgetsPerRow" : 2
          },
          "period" : 300,
          "splitBy" : "",
          "region" : "us-east-1"
        }
      }
    ]
  })
}
