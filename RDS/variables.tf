
variable "engine" {
  description = "PostgreSQL database engine"
  type        = string
}
variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the DB"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "allocated_storage" {
  description = "Initial storage allocation"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage allocation"
  type        = number
  default     = 100
}

variable "username" {
  description = "Database username"
  type        = string
}

variable "maintenance_window" {
  description = "Preferred maintenance window for the RDS instance"
  type        = string
}

variable "backup_window" {
  description = "Preferred backup window for the RDS instance"
  type        = string
}

variable "backup_retention_period" {
  description = "Number of days to retain RDS automated backups"
  type        = number
}


variable "team-emails" {
  type        = list(string)
  description = "Team email ids"
  default     = ["sandeepk1210@gmail.com"]
}

variable "cpu_utilization_high_period_seconds" {
  type    = number
  default = 300
}

variable "cpu_utilization_high_statistic" {
  type    = string
  default = "Average"
}

variable "cpu_utilization_high_threshold_percent" {
  type    = number
  default = 80
}
