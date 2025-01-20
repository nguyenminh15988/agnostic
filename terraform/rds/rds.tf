resource "aws_rds_cluster" "main" {
  cluster_identifier = "devops-db-cluster"
  engine             = "mysql"
  engine_version     = "8.0"
  master_username    = var.db_user
  master_password    = var.db_password

  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
}

resource "aws_rds_cluster_instance" "replica" {
  count                 = 2
  cluster_identifier    = aws_rds_cluster.main.id
  instance_class        = "db.t3.medium"
  engine                = aws_rds_cluster.main.engine
}
