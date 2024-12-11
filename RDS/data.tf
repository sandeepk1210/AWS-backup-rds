data "aws_caller_identity" "current" {}

data "aws_vpc" "main" {
  default = false
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
