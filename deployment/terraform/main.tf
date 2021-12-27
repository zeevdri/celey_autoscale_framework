variable "project-prefix" {
  type = string
  default = "celery-autoscale"
  nullable = false
}

variable "env-type" {
  type = string
  default = "test"
  nullable = false
}

variable "env-suffix" {
  type = number
  default = 1
  nullable = false
}

variable "aws-region" {
  type = string
  default = "eu-central-1"
  nullable = false
  description = "the region where to deploy"
  validation {
    condition = can(regexall("(?:eu|us|af|ap|ca|sa|me)-(?:west|east|north|south|central)-\\d", var.aws-region))
    error_message = "Aws-region must be a valid aws region e.g. eu-central-1."
  }
}

locals {
  project_qualifier = "${var.project-prefix}-${var.env-type}${var.env-suffix}"
}

locals {
  common_tags = {
    Project = local.project_qualifier
    Environment = terraform.workspace
  }
}

provider "aws" {
  region = var.aws-region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"
  availability_zones = data.aws_availability_zones.available.names
  prefix = local.project_qualifier
  private_subnet_cidr_block = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnet_cidr_block = []
  common_tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"
  availability_zones = data.aws_availability_zones.available.names
  prefix = local.project_qualifier
  private_subnet = module.vpc.private_subnets[*].id
}
