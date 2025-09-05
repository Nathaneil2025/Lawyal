# aws-auth.tf

# This only manages RBAC access (maps IAM roles/users to Kubernetes RBAC)
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
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

  depends_on = [
    aws_eks_cluster.cluster
  ]
}
