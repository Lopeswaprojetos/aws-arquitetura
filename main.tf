terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_attachment" "gw_attach" {
  vpc_id       = aws_vpc.main.id
  internet_gateway_id = aws_internet_gateway.gw.id
}

resource "aws_elb" "web-lb" {
  name               = "web-lb"
  availability_zones = ["us-east-1a", "us-east-1b"]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_launch_configuration" "data-processing-lc" {
  image_id        = "ami-123456"
  instance_type   = "t2.micro"
}

resource "aws_autoscaling_group" "data-processing-asg" {
  launch_configuration = aws_launch_configuration.examplo.id
  min_size             = 2
  max_size             = 10
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_nat_gateway" "teste-nat-gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id
}

resource "aws_s3_bucket" "my-test-bucket" {
  bucket = "my-bucket-name"
}

resource "aws_route53_zone" "teste-exemplo-zone" {
  name = "teste.exemplo.com"
}

resource "aws_cloudfront_distribution" "static-website-distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.website_endpoint
    origin_id   = "S3-my-bucket"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3-my-bucket"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
} 

resource "aws_waf_web_acl" "web-security-acl" {
  name        = "web-security-acl"
  metric_name = "web-security-acl"

  default_action {
    type = "ALLOW"
  }


rule {
    name        = "block-all"
    priority    = 1
    action      = "BLOCK"
    override_action = {
      type = "NONE"
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
  }
}

resource "aws_vpc_endpoint" "dynamodb-endpoint" {
  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.us-east-1.dynamodb"
}

resource "aws_cloudwatch_metric_alarm" "ec2-cpu_utilization_alarm" {
  alarm_name          = "ec2-cpu_utilization_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name        = "CPUUtilization_alarm"
  namespace          = "AWS/EC2"
  period             = 120
  statistic          = "Average"
  threshold          = 80

  dimensions {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  alarm_description = "This metric monitors EC2 instance CPU utilization"
  alarm_actions     = ["arn:aws:sns:us-east-1:123456789012:my-sns-topic"]
}
