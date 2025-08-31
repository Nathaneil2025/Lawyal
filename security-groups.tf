# Security group for worker nodes
resource "aws_security_group" "nodes" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-eks-nodes-sg"
    Project = var.project_name
  }
}

# Allow node-to-node all traffic (within SG)
resource "aws_security_group_rule" "nodes_intra" {
  type                     = "ingress"
  description              = "Node to node"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.nodes.id
}

# (Optional) SSH to public node group (lock this to your IP!)
resource "aws_security_group_rule" "ssh_public_nodes" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nodes.id
  cidr_blocks       = [var.ssh_ingress_cidr]
}

# Allow control-plane -> nodes (EKS creates a cluster SG; we allow it to reach nodes)
resource "aws_security_group_rule" "controlplane_to_nodes_ephemeral" {
  type                     = "ingress"
  description              = "Control plane to nodes (ephemeral & HTTPS)"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "controlplane_to_nodes_https" {
  type                     = "ingress"
  description              = "Control plane to nodes (HTTPS)"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}
