variable "region" {
    description = " AWS Region "
    type        = string
    default     = "ap-south-1"
}

variable "vpc_name" {
    description = "Name tag of the VPC "
    type        = string
    default      = "demo-vpc"
}

variable "ami_id" {
     description = "AMI ID for EC2 instances"
     type        = string
     default     = "ami-0f5ee92e2d63afc18"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "Devops_Demo_project" 
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}