variable "aws_region" {
  description = "AWS region (Learner Lab is locked to us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name and tag all resources"
  type        = string
  default     = "ecommerce-devops-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is allowed in Learner Lab)"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of app EC2 instances to launch (in private subnets)"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Existing EC2 key pair. Learner Lab provides 'vockey' by default."
  type        = string
  default     = "vockey"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the bastion. 0.0.0.0/0 lets the GitHub runner connect."
  type        = string
  default     = "0.0.0.0/0"
}
