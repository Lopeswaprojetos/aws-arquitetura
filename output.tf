output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  valu = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
}

output "load_balancer_dns_name" {
  value = aws_elb.web-lb.dns_name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.data-processing-asg.name
}

output "nat_gateway_id" {
  value = aws_nat_gateway.test-nat-gateway.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my-test-bucket.bucket
}
