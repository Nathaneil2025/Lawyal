variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "A short name used for tags and resource names"
  type        = string
  default     = "lawyal"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR (eu-central-1a)"
  type        = string
  default     = "192.168.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR (eu-central-1b)"
  type        = string
  default     = "192.168.1.0/24"
}

variable "az_public" {
  description = "AZ for public subnet"
  type        = string
  default     = "eu-central-1a"
}

variable "az_private" {
  description = "AZ for private subnet"
  type        = string
  default     = "eu-central-1b"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "key_name" {
  description = "EC2 key pair name for SSH (managed nodegroups)"
  type        = string
  default     = "Frankfurt"
}

variable "instance_types" {
  description = "Instance types for node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ng_desired_size" {
  type        = number
  default     = 2
}

variable "ng_min_size" {
  type        = number
  default     = 1
}

variable "ng_max_size" {
  type        = number
  default     = 3
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH to nodes in public subnet (update to your IP!)"
  type        = string
  default     = "0.0.0.0/0" # ⚠️ change to your IP/CIDR for security
}
