#Configuration for eks cluster

resource "aws_eks_cluster" "Cali-eks" {
  name     = var.eks-name
  enabled_cluster_log_types = ["api", "audit"]
  role_arn = aws_iam_role.eks_cluster_iam_role.arn
  security_group_ids=[aws_security_group.eks_SG.id]
  vpc_config {
    subnet_ids = [var.aws_priv_subnet1_id, var.aws_pub_subnet2_id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.cloudwatch_log_group
  ]
 }

resource "aws_iam_role" "eks_cluster_iam_role" {
  name = var.eks_cluster_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_iam_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_iam_role.name
}
# output "endpoint" {
#   value = aws_eks_cluster.example.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.example.certificate_authority[0].data
# }

#security Group for the eks cluster

resource "aws_security_group" "eks_SG" {
  name        = var.eks_SG_name
  description = "Allow http/Https traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_http"
  }
}

# iam policies for the cloudwatch log group

resource "aws_iam_policy" "AmazonEKSClusterCloudWatchMetricsPolicy" {
  name   = "AmazonEKSClusterCloudWatchMetricsPolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
policy_arn = aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
role       = aws_iam_role.eks_cluster_iam_role.name
}
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
name = "/aws/eks/${var.eks_cluster_name}/cluster"
retention_in_days = 7
}

