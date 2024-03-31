output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "ID of public subnet A"
  value       = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  description = "ID of public subnet B"
  value       = aws_subnet.public_subnet_b.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.my-test-bucket.bucket
}

output "route53_zone_id" {
  description = "ID of the Route 53 zone"
  value       = aws_route53_zone.teste-exemplo-zone.zone_id
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static-website-distribution.id
}
