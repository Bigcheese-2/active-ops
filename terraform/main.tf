# Tell Terraform we are using the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Configure the Kubernetes provider for aws-auth module
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# --- 1. Create a VPC (Virtual Private Cloud) ---
# A VPC is your own private, isolated network in AWS.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = var.cluster_name
  cidr = "10.0.0.0/16" # The IP address range for your network

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true # Allows your private app to talk to the internet
}

# --- 2. Create the EKS (Kubernetes) Cluster ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  # Enable cluster creator admin permissions so Terraform can authenticate and manage aws-auth
  enable_cluster_creator_admin_permissions = true

  # Pass in the network details from the VPC we just made
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # This creates the "worker nodes" 
  eks_managed_node_groups = {
    main = {
      min_size     = 1 # Start with 1 server
      max_size     = 2 # Can scale up to 2
      desired_size = 1
      instance_types = ["t3.small"] 
    }
  }
}

# --- 3. Manage AWS Auth ConfigMap ---
# This module manages the aws-auth ConfigMap to grant IAM user access to the cluster
module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.8.4"

  manage_aws_auth_configmap = true

  # This adds IAM user as an administrator
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::453390112342:user/yemiops"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  depends_on = [module.eks]
}