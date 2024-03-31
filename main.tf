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
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_a_cidr_block
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_b_cidr_block
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_elb" "web-lb" {
  name               = "web-lb"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  subnets = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_launch_configuration" "data-processing-lc" {
  image_id      = var.ami_id
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "data-processing-asg" {
  launch_configuration = aws_launch_configuration.data-processing-lc.id
  min_size             = 2
  max_size             = 10
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "teste-nat-gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "MyNatGateway"
  }
}

resource "aws_s3_bucket" "my-test-bucket" {
  bucket = "my-bucket-name"
}

resource "aws_route53_zone" "teste-exemplo-zone" {
  name = "teste.exemplo.com"
}

resource "aws_cloudfront_distribution" "static-website-distribution" {
  origin {
    domain_name = aws_s3_bucket.my-test-bucket.bucket_regional_domain_name
    origin_id   = "S3-my-bucket"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
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
  metric_name = "web_security_acl_metric"

  default_action {
    type = "ALLOW"
  }

  # Adicione suas regras aqui conforme necessário
}

resource "aws_vpc_endpoint" "dynamodb-endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.dynamodb"
}

resource "aws_cloudwatch_metric_alarm" "ec2-cpu_utilization_alarm" {
  alarm_name          = "ec2-cpu_utilization_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization_alarm"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.data-processing-asg.name
  }

  alarm_description = "This metric monitors EC2 instance CPU utilization"
  alarm_actions     = ["arn:aws:sns:us-east-1:123456789012:my-sns-topic"]
}
