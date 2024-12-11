# IAM Role EBRBackupServiceRole for AWS Backup
resource "aws_iam_role" "EBRBackupServiceRole" {
  name               = "EBRBackupServiceRole"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role_policy.json

  tags = {
    Name = "EBRBackupServiceRole"
  }
}

# IAM Policy Document for Assume Role Policy
data "aws_iam_policy_document" "backup_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

# Attach the required policy to the role
resource "aws_iam_role_policy_attachment" "EBRBackupServiceRoleForBackupPolicyAttachment" {
  role       = aws_iam_role.EBRBackupServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "EBRBackupServiceRoleForRestorePolicyAttachment" {
  role       = aws_iam_role.EBRBackupServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy_attachment" "EBRBackupServiceRoleForS3BackupPolicyAttachment" {
  role       = aws_iam_role.EBRBackupServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_iam_role_policy_attachment" "EBRBackupServiceRoleForS3RestorePolicyAttachment" {
  role       = aws_iam_role.EBRBackupServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
}

# # Optional: Attach a custom backup policy if needed (Example)
# resource "aws_iam_policy" "custom_backup_policy" {
#   name        = "CustomBackupPolicy"
#   description = "Custom policy for backup operations"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "backup:StartBackupJob",
#           "backup:StopBackupJob",
#           "backup:ListBackupJobs",
#           "backup:DescribeBackupVault",
#           "backup:CreateBackupPlan"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach the custom backup policy to the role (optional)
# resource "aws_iam_role_policy_attachment" "EBRBackupServiceRoleCustomPolicyAttachment" {
#   role       = aws_iam_role.EBRBackupServiceRole.name
#   policy_arn = aws_iam_policy.custom_backup_policy.arn
# }
