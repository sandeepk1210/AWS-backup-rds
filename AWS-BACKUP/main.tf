# Create a KMS Key for Encryption
resource "aws_kms_key" "backup_vault_key" {
  description             = "KMS key for AWS Backup Vault encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
}

# Optional: Alias for the KMS Key
resource "aws_kms_alias" "backup_vault_alias" {
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.backup_vault_key.id
}

# Backup Vault to store backups
resource "aws_backup_vault" "database_vault" {
  name        = var.backup_vault_name
  kms_key_arn = aws_kms_key.backup_vault_key.arn

  tags = merge(local.common_tags, {
    "VaultType" = "BackupVault"
  })
}

# Define a reusable function to create backup plans with schedules
resource "aws_backup_plan" "database_backup_plan" {
  count = length(var.backup_schedules)

  name = "ebr-np-daily-snap-${var.backup_retention_period}day-${var.backup_schedules[count.index].time}"

  rule {
    rule_name         = "dailysnap${var.backup_retention_period}dayretention-${var.backup_schedules[count.index].time}"
    target_vault_name = aws_backup_vault.database_vault.name
    schedule          = var.backup_schedules[count.index].cron_expression
    lifecycle {
      delete_after = var.backup_retention_period # Retain backups for 14 days
    }
  }
}

# # Backup Selection to associate resources with the backup plan
resource "aws_backup_selection" "database_backup_selection" {
  count = length(var.backup_schedules)

  name         = "dailysnap${var.backup_retention_period}dayretention-${var.backup_schedules[count.index].time}"
  plan_id      = aws_backup_plan.database_backup_plan[count.index].id
  iam_role_arn = aws_iam_role.EBRBackupServiceRole.arn

  resources = [
    var.rds_instance_arn
  ]

  # Adding the resource_tag filter to select resources based on tag values
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "AWSEBRBackup"
    value = "DS${var.backup_retention_period}-${var.backup_schedules[count.index].time}"
  }
}
