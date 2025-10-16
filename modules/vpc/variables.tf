variable "vpc_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}


variable "enable_peering" {
  type = string
}

variable "peer_vpc_id" {
  type = string
  default = null
}

variable "peer_region" {
  type = string
  default = null
}

variable "auto_accept_peering" {
  type = bool
  default = true
}