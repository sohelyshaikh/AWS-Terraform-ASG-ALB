variable "vpc_cidr" {}

variable "public_cidrs" {
  type = list(any)
}

variable "private_cidrs" {
  type = list(any)
}