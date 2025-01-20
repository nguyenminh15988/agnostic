resource "aws_eks_node_group" "workers" {
  cluster_name    = module.eks.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.main[*].id

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [
      aws_security_group.worker_sg.id
    ]
  }

  tags = {
    Environment = var.environment
  }
}

# Outputs
output "node_group_name" {
  value = aws_eks_node_group.workers.node_group_name
}
