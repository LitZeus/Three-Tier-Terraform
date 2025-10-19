variable "vpc_id" {
  description = "VPC ID where SG should be created"
  type        = string
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    sg_ids      = optional(list(string))  # optional: allow traffic from other SGs
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    sg_ids      = optional(list(string))  # optional: allow traffic to other SGs
  }))
  default = []
}
