variable "rds_instance_arn" {
  description = "ARN of the RDS instance to associate with the backup"
  type        = string
}

variable "backup_schedules" {
  description = "Schedules for backup in cron expression with time labels"
  type = list(object({
    cron_expression = string
    time            = string
  }))
}

variable "backup_vault_name" {
  description = "Name for the AWS Backup Vault"
  type        = string
}

variable "kms_key_deletion_window" {
  description = "The number of days before a KMS key is deleted"
  type        = number
  default     = 7
}

variable "kms_key_alias" {
  description = "Alias for the KMS key"
  type        = string
}

variable "backup_retention_period" {
  description = "Number of days to retain the backups"
  type        = number
}
