provider "aws" {
  region = var.region
}

# Fetch cluster details after it's created
data "aws_eks_cluster" "this" {
  name       = aws_eks_cluster.cluster.name
  depends_on = [aws_eks_cluster.cluster]
}

data "aws_eks_cluster_auth" "this" {
  name       = aws_eks_cluster.cluster.name
  depends_on = [aws_eks_cluster.cluster]
}

# Kubernetes provider now waits until cluster is ready
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token

  # Helps avoid race conditions on new clusters
  experiments {
    manifest_resource = true
  }
}
