#
# Local Resources
#

data "archive_file" "shorturl" {
  type        = "zip"
  source_file = "lambda/lambda.py"
  output_path = "lambda/lambda.zip"
}

#
# Global Backend Resources
#

resource "aws_iam_role" "shorturl" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "shorturl" {
  role = aws_iam_role.shorturl.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_dynamodb_global_table" "global_table" {
  depends_on = ["module.shorturl_eu", "module.shorturl_us"]

  name = "shorturls"

  replica {
    region_name = "eu-west-1"
  }

  replica {
    region_name = "us-east-1"
  }
}


#
# AWS Global Accelerator
#

resource "aws_globalaccelerator_accelerator" "ga" {
  name            = "ga"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "ga" {
  accelerator_arn = aws_globalaccelerator_accelerator.ga.id
  protocol        = "TCP"
  client_affinity = "SOURCE_IP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

# Global Accelerator Endpoint Groups are part of the module backend


#
# Backend Module
# ALB + Lambda + DynamoDB + GA Endpoint Groups
#

module "shorturl_us" {
  source = "./backend"

  lambda_role = aws_iam_role.shorturl.arn
  ga_listener = aws_globalaccelerator_listener.ga.id
}

module "shorturl_eu" {
  source = "./backend"
  providers = {
    aws = "aws.eu"
  }

  lambda_role = aws_iam_role.shorturl.arn
  ga_listener = aws_globalaccelerator_listener.ga.id
}

output "ga_ips" {
  value = aws_globalaccelerator_accelerator.ga.ip_sets
}
