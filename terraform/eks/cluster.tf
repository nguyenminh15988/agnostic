module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  # Networking
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.main[*].id

  # Node group
  node_groups = {
    workers = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 2
      instance_type    = "t3.medium"
    }
  }
}
