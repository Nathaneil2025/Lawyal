data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          # Restrict to your repo
          "token.actions.githubusercontent.com:sub" = "repo:Nathaneil2025/Lawyal:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_destroy" {
  name = "GitHubActionsDestroyPolicy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          # EKS
          "eks:DeleteCluster",
          "eks:DescribeCluster",
          "eks:ListNodegroups",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:UpdateNodegroupConfig",

          # Auto Scaling (for backing ASGs of nodegroups)
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",

          # EC2
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DeleteNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteSubnet",
          "ec2:DeleteVpc",
          "ec2:DeleteNatGateway",
          "ec2:ReleaseAddress",
          "ec2:DeleteRouteTable",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:Describe*",

          # ELB
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",

          # ECR
          "ecr:BatchDeleteImage",
          "ecr:DeleteRepository",
          "ecr:ListImages",
          "ecr:DescribeRepositories",

          # DynamoDB (for TF state locks)
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ],
        Resource = "*"
      }
    ]
  })
}
