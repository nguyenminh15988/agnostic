output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = aws_rds_cluster.main.endpoint
}
