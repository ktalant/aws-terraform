#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "talant-node-role" {
  name = "terraform-eks-node-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "talant-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.talant-node-role.name
}

resource "aws_iam_role_policy_attachment" "talant-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.talant-node-role.name
}

resource "aws_iam_role_policy_attachment" "talant-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.talant-node-role.name
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.talant-cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.talant-node-role.arn
  subnet_ids      = aws_subnet.talant_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.talant-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.talant-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.talant-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
