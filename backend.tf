terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "lawyal-terraform-state"
    key            = "infra/eks/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    # We'll configure kubernetes/helm later in steps 3-4
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}
