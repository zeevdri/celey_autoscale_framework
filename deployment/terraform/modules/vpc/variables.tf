variable "availability_zones" {
  type = list(string)
  description = "AWS Region Availability Zones"
}

variable "public_subnet_cidr_block" {
  type = list(string)
  description = "Public Subnet CIDR Block"
}

variable "private_subnet_cidr_block" {
   type = list(string)
   description = "Private Subnet CIDR Block"
}

//variable "database_subnet_cidr_block" {
//   type = "list"
//   description = "Database Subnet CIDR Block"
//}

variable "prefix" {
  type = string
  nullable = false
}

variable "common_tags" {
  type = map(string)
  nullable = false
  default = {}
}