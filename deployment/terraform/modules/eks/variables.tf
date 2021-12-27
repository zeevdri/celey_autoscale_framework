variable "availability_zones" {
  type = list(string)
  description = "AWS Region Availability Zones"
}

variable "private_subnet" {
   type = list(number)
   description = "Subnet Ids"
}

variable "prefix" {
  type = string
  nullable = false
}

variable "common_tags" {
  type = map(string)
  nullable = false
  default = {}
}