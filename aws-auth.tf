data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  provider = kubernetes  # 👈 explicitly tell TF to use the Kubernetes provider

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        # Worker nodes → required for nodes to join
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        # GitHub Actions role → cluster admin (CI/CD)
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsRole"
        username = "github-runner"
        groups   = ["system:masters"]
      }
    ])

    mapUsers = jsonencode([
      {
        # Your IAM user → cluster admin
        userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Nateuser"
        username = "nate"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [
    aws_eks_cluster.cluster
  ]

  lifecycle {
    # Avoid recreate loops (aws-auth usually exists already)
    create_before_destroy = true
    ignore_changes        = [metadata]
  }
}
