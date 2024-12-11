module "app-db" {
  source         = "./RDS"
  engine         = "17"
  engine_version = "17.1"
  instance_class = "db.t4g.micro"
  db_name        = "appdb2"
  username       = "postgres"
  // Duration for maintenance window: AWS uses the minimum time necessary, but you should allocate 3 hours 
  //  to ensure sufficient time for updates (default is 30 minutes to 3 hours).
  // Duration for backup window: AWS recommends a 30-minute to 2-hour window, depending on your database size and workload.
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "04:00-06:00"
  backup_retention_period = 7
}
