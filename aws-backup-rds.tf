module "aws-backup-rds" {
  source = "./AWS-BACKUP"
  # Output variable of the App DB to get the RDS ARN
  rds_instance_arn        = module.app-db.rds_instance_arn
  backup_retention_period = 14
  backup_vault_name       = "EBRBackup-vault"
  kms_key_alias           = "alias/backup-vault-key"
  backup_schedules = [
    {
      cron_expression = "cron(0 21 * * ? *)"
      time            = "9PM"
    },
    {
      cron_expression = "cron(0 22 * * ? *)"
      time            = "10PM"
    },
    {
      cron_expression = "cron(0 23 * * ? *)"
      time            = "11PM"
    },
    {
      cron_expression = "cron(0 1 * * ? *)"
      time            = "1AM"
    },
    {
      cron_expression = "cron(0 2 * * ? *)"
      time            = "2AM"
    },
    {
      cron_expression = "cron(0 0 * * ? *)"
      time            = "12AM"
    }
  ]
}
