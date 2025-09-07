############################################
# EKS Cluster
############################################
resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = [aws_subnet.public.id, aws_subnet.private.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_vpc.main,
    aws_subnet.public,
    aws_subnet.private,
    aws_internet_gateway.igw,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_VPCResourceController
  ]

  tags = {
    Name    = "${var.project_name}-eks"
    Project = var.project_name
  }
}

############################################
# IAM Policies for Worker Node Role
############################################
resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################
# Node Group (Public Subnet)
############################################
resource "aws_eks_node_group" "public_ng" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.project_name}-public-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.public.id]
  instance_types  = var.instance_types

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = [aws_security_group.nodes.id]
  }

  update_config {
    max_unavailable = 1
  }

  ami_type = "AL2_x86_64"

  labels = {
    role = "public"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    
    aws_security_group_rule.controlplane_to_nodes_ephemeral,
    aws_security_group_rule.controlplane_to_nodes_https,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Project = var.project_name
  }
}

############################################
# Node Group (Private Subnet)
############################################
resource "aws_eks_node_group" "private_ng" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.project_name}-private-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private.id]
  instance_types  = var.instance_types

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  ami_type = "AL2_x86_64"

  labels = {
    role = "private"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    
    aws_security_group_rule.controlplane_to_nodes_ephemeral,
    aws_security_group_rule.controlplane_to_nodes_https,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Project = var.project_name
  }
}
