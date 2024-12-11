
output "backup_vault_arn" {
  value = aws_backup_vault.database_vault.arn
}

output "kms_key_arn" {
  value = aws_kms_key.backup_vault_key.arn
}

# Output for the KMS Key ARN
output "backup_vault_kms_key_arn" {
  description = "The ARN of the KMS key used for encrypting backups"
  value       = aws_kms_key.backup_vault_key.arn
}

# Output for the Backup Vault Name
output "backup_vault_name" {
  description = "The name of the AWS Backup Vault"
  value       = aws_backup_vault.database_vault.name
}

# Output for the Backup Plan IDs
output "backup_plan_ids" {
  description = "The IDs of the backup plans created"
  value       = aws_backup_plan.database_backup_plan[*].id
}

# Output for the Backup Selection Names
output "backup_selection_names" {
  description = "The names of the backup selections created"
  value       = aws_backup_selection.database_backup_selection[*].name
}
