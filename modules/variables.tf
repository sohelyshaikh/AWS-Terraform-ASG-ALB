variable "vpc" {
  default = "${terraform.workspace}" == "dev" ? "10.100.0.0/16" : "${terraform.workspace}" == "staging" ? "10.200.0.0/16" : "10.300.0.0/16"
}

variable "cidr" {
  type    = list(any)
  default = "${terraform.workspace}" == "dev" ? ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"] : "${terraform.workspace}" == "staging" ? ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"] : ["10.300.1.0/24", "10.300.2.0/24", "10.300.3.0/24"]
}

variable "cidrpub" {
  type    = list(any)
  default = "${terraform.workspace}" == "dev" ? ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"] : "${terraform.workspace}" == "staging" ? ["10.200.4.0/24", "10.200.5.0/24", "10.200.6.0/24"] : ["10.300.4.0/24", "10.300.5.0/24", "10.300.6.0/24"]

}

variable "instancetype" {
  type    = string
  default = "${terraform.workspace}" == "dev" ? "t3.micro" : "${terraform.workspace}" == "staging" ? "t3.small" : "t3.medium"
}