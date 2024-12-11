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
