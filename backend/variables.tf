resource "aws_default_vpc" "default" {
}

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.default.id
}

data "aws_security_groups" "sgs" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

variable "lambda_role" {
  type = string
}

variable "ga_listener" {
  type = string
}