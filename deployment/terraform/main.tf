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
    condition = can(regex("^(eu|us|af|ap|ca|sa|me)-(west|east|north|south|central|)-\d+$", var.aws-region))
    error_message = "aws-region must be a valid aws region e.g. eu-central-1"
  }
}

locals {
  project_qualifier = "${var.project-prefix}-${var.env-type}${var.env-suffix}"
}

locals {
  common_tags = {
    Project = local.project_qualifier
  }
}

provider "aws" {
  region = var.aws-region
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = merge({
    Name = "${local.project_qualifier}-vpc"
  }, local.common_tags)
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = merge({
    Name = "${local.project_qualifier}-private-subnet"
  }, local.common_tags)
}


resource "aws_iam_role" "eks-role" {
  name = "${local.project_qualifier}-eks"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks-role.name
}

resource "aws_eks_cluster" "eks-cluster01" {
  name = "${local.project_qualifier}-01"
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private.id]
  }

  tags = local.common_tags

  enabled_cluster_log_types = [
    "api",
    "audit"]

  depends_on = [
    aws_cloudwatch_log_group.eks-log-group,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_cloudwatch_log_group" "eks-log-group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name = "/aws/eks/${aws_eks_cluster.eks-cluster01.name}/cluster"
  retention_in_days = 7

  # ... potentially other configuration ...
}

resource "aws_eks_node_group" "cpu-node-group" {
  cluster_name = aws_eks_cluster.eks-cluster01
  node_group_name = "cpu-test01"
  node_role_arn = aws_iam_role.eks-role.arn
  subnet_ids = aws_subnet.private[*].id

  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  tags = local.common_tags

  capacity_type = "SPOT"
  instance_types = [
    "t3.nano"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "gpu-node-group" {
  cluster_name = aws_eks_cluster.eks-cluster01
  node_group_name = "gpu-test01"
  node_role_arn = aws_iam_role.eks-role.arn
  subnet_ids = aws_subnet.private[*].id

  tags = local.common_tags

  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  capacity_type = "SPOT"
  instance_types = [
    "t3.micro"]

  taint = [
    {
      key : "gpu",
      effect : "NO_SCHEDULE"
    }
  ]

  labels = {
    gpu : 1
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks-node-group-role" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks-node-group-role.name
}