variable "team-emails" {
    type = list(string)
    description = "Team email ids"
    default = ["sandeepk1210@gmail.com"]
}

variable "cpu_utilization_high_period_seconds" {
    type = number
    default = 300
}

variable "cpu_utilization_high_statistic" {
    type = string
    default = "Average"
}

variable "cpu_utilization_high_threshold_percent" {
    type = number
    default = 80
}