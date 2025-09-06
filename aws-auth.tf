# Get current AWS account details
data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
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
        # GitHub Actions role (if you need CI/CD later)
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsRole"
        username = "github-runner"
        groups   = ["system:masters"]
      }
    ])

    mapUsers = jsonencode([
      {
        userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Nateuser"
        username = "nate"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [aws_eks_cluster.cluster]

  lifecycle {
    # Prevent "already exists" error by letting TF adopt the resource
    create_before_destroy = true
    ignore_changes        = [metadata]
  }
}
