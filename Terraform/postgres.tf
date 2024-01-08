# US Postgres Service
resource "aiven_pg" "pg1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  service_name = "pg1"
  plan         = "business-4"
  maintenance_window_dow  = var.maintenance_dow
  maintenance_window_time = var.maintenance_time
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


resource "aiven_service_integration" "pg1_to_pg1" {
  project                  = var.project_name
  integration_type         = "metrics"
  source_service_name      = aiven_pg.pg1.service_name
  destination_service_name = aiven_pg.pg1.service_name
  depends_on = [aiven_pg_database.pg1db1]
}


resource "aiven_service_integration" "pg1_to_os1" {
  project                  = var.project_name
  integration_type         = "logs"
  source_service_name      = aiven_pg.pg1.service_name
  destination_service_name = aiven_opensearch.os1.service_name
  depends_on = [aiven_pg_database.pg1db1, aiven_opensearch.os1]
}


output "pg1_connect"{
  value = aiven_pg.pg1.service_uri
  sensitive = true
}

output "pg1_command"{
  value = format("export PGPASSWORD=%s;export PGHOST=%s;export PGPORT=%s;export PGUSER=%s;export PGDATABASE=%s;psql",
    sensitive(aiven_pg.pg1.service_password),
    aiven_pg.pg1.service_host,
    aiven_pg.pg1.service_port,
    sensitive(aiven_pg.pg1.service_username),
    aiven_pg_database.pg1db1.database_name)
  sensitive = true
}


output "pg1_host_port"{
  value = format("%s:%s", aiven_pg.pg1.service_host, aiven_pg.pg1.service_port)
}
