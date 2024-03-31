variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_a_cidr_block" {
  description = "CIDR block for public subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_b_cidr_block" {
  description = "CIDR block for public subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "Instance type for the launch configuration"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the launch configuration"
  type        = string
  default     = "ami-123456"
}
