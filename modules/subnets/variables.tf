variable "vpc_id" {
  description = "VPC ID in which to create subnets"
  type        = string
}

variable "subnet_cidrs" {
  description = "List of subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public" {
  description = "Whether the subnet is public or private"
  type        = bool
}