variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# EC2 Instance Configuration
variable "ami_id" {
  description = "The Amazon Machine Image (AMI) ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
}
