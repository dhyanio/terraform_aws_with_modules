# This is a main_vpc_dhyanio's vpc variable terraform file.
# i ma using list type variable for below 2 variable bcos, in main.tf i am calling two ips

variable "private_cidrs" {
  type = "list"
}

variable "vpc_cidr" {}

variable "public_cidrs" {
  type = "list"
}

