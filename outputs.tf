output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_ca_base64" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "eks_oidc_issuer" {
  value = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.flask_app.repository_url
}

output "kubectl_update_command" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.cluster.name} --region ${var.region}"
}
