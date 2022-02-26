provider "aws" {
    region = "eu-west-1"
}

data "aws_availability_zones" "zones_available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.48"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs                  = slice(data.aws_availability_zones.zones_available.names, 0, 2)
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.2.3"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.public_subnets  
  vpc_id          = module.vpc.vpc_id

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.medium"]
  }

  eks_managed_node_groups = {
    green = {
      subnet_ids   = ["subnet-07b1c6e44b9873ba8"]
#      subnet_ids   = module.vpc.public_subnets[0]
      min_size     = 1
      max_size     = 10
      desired_size = 3
      public_ip    = true

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
#      taints = {
#        dedicated = {
#          key    = "dedicated"
#          value  = "gpuGroup"
#          effect = "NO_SCHEDULE"
#        }
#      }
      tags = {
        ExtraTag = "example"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
    }
    node_port = {
      description      = "Node port"
      protocol         = "TCP"
      from_port        = 30000
      to_port          = 30002
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
