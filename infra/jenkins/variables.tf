variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
