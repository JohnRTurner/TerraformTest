# US Postgres Service
resource "aiven_pg" "pg1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  service_name = "pg1"
  plan         = "business-4"
  pg_user_config {
    admin_username = var.pg_user
    admin_password = var.pg_password
  }
}

resource "aiven_pg_database" "pg1db1" {
  project                 = var.project_name
  service_name  = aiven_pg.pg1.service_name
  database_name = "pg1db1"
  provisioner "local-exec" {
    command = format("export PGPASSWORD=%s;export PGHOST=%s;export PGPORT=%s;export PGUSER=%s;export PGDATABASE=%s;psql --file=postgres1.sql > out/postgres1.out 2>&1",
      sensitive(aiven_pg.pg1.service_password),
      aiven_pg.pg1.service_host,
      aiven_pg.pg1.service_port,
      sensitive(aiven_pg.pg1.service_username),
      aiven_pg_database.pg1db1.database_name)
  }
}

output "pg1_connect"{
  value = aiven_pg.pg1.service_uri
  sensitive = true
}

output "pg1_host_port"{
  value = format("%s:%s", aiven_pg.pg1.service_host, aiven_pg.pg1.service_port)
}
