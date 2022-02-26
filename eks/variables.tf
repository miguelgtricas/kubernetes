variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    default     = "training-cluster"
}

variable "cluster_version" {
    description = "The Kubernetes version running on the EKS cluster"
    type        = string
    default     = "1.21"
}

variable "vpc_name" {
    description = "The name of the VPC"
    type        = string
    default     = "EKS-VPC"
}

variable "vpc_cidr_block" {
    description = "The CIDR block of the VPC"
    type = string
    default     = "192.168.0.0/16"
}

variable "private_subnets" {
    description = "The CIRD of the private subnets"
    type        = list
    default     = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "public_subnets" {
    description = "The CIRD of the public subnets"
    type        = list
    default     = ["192.168.3.0/24", "192.168.4.0/24"]
}

variable "workers_asg_max_size" {
    description = "Maximum nomber of workers"
    type        = string
    default     = 1
}

variable "workers_instance_type" {
    description = "EC2 worker instance type"
    type        = string
    default     = "t2.medium"
}
