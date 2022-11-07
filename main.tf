provider "aws" {
  profile = "bkash"
  region  = var.aws_region
}

module "vpc" {
  source = "./modules/vpc/"
}

### create cluster role 
resource "aws_iam_role" "cluster_role" {
  name = "cluster_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Created_By  = module.vpc.common_tags["Created_By"]
    Environment = module.vpc.common_tags["Environment"]
    Name        = "cluster_role"
  }
}

### attach aws managed policy arn  to cluster role 
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

### create node role 
resource "aws_iam_role" "node_role" {
  name = "node_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Created_By  = module.vpc.common_tags["Created_By"]
    Environment = module.vpc.common_tags["Environment"]
    Name        = "node_role"
  }
}

### attach aws managed policy arn  to node role 
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#### create eks cluster 
resource "aws_eks_cluster" "bkash" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = [module.vpc.public_sub1.id, module.vpc.public_sub2.id, module.vpc.public_sub3.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}

## create eks cluster node-group 
resource "aws_eks_node_group" "bkash_nodes" {
  cluster_name    = aws_eks_cluster.bkash.name
  node_group_name = "bkash_nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [module.vpc.public_sub1.id, module.vpc.public_sub2.id, module.vpc.public_sub3.id]
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}
