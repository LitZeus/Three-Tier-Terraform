variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 should be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Optional user data script for bootstrapping"
  type        = string
  default     = ""
}