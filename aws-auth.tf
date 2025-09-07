# Get current AWS account details
data "aws_caller_identity" "current" {}

# Build aws-auth manifest as YAML but DO NOT apply with Terraform
locals {
  aws_auth_configmap = yamlencode({
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "aws-auth"
      namespace = "kube-system"
    }
    data = {
      mapRoles = jsonencode([
        {
          # Worker nodes
          rolearn  = aws_iam_role.eks_node_role.arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:bootstrappers", "system:nodes"]
        },
        {
          # GitHub Actions role → cluster admin
          rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsRole"
          username = "github-runner"
          groups   = ["system:masters"]
        }
      ])
      mapUsers = jsonencode([
        {
          # Human IAM user → cluster admin
          userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Nateuser"
          username = "nate"
          groups   = ["system:masters"]
        }
      ])
    }
  })
}

# Output the manifest so you can apply it manually or in CI/CD
output "aws_auth_manifest" {
  value = local.aws_auth_configmap
}
