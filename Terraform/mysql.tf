resource "aiven_mysql" "mysql1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  service_name            = "mysql1"
  maintenance_window_dow  = var.maintenance_dow
  maintenance_window_time = var.maintenance_time

  mysql_user_config {
    admin_username = var.mysql_user
    admin_password = var.mysql_password
    mysql_version  = 8

    public_access {
      mysql = true
    }
  }
}

resource "aiven_mysql_database" "mysql1db1" {
  project       = var.project_name
  service_name  = aiven_mysql.mysql1.service_name
  database_name = "mysqldb1"
  provisioner "local-exec" {
    command = format("mysql --host=%s --port=%s --user=%s --password=%s %s < mysql1.sql > out/mysql1.out 2>&1",
      aiven_mysql.mysql1.service_host,
      aiven_mysql.mysql1.service_port,
      sensitive(aiven_mysql.mysql1.service_username),
      sensitive(aiven_mysql.mysql1.service_password),
      aiven_mysql_database.mysql1db1.database_name)
  }
}

resource "aiven_service_integration" "mysq1_to_pg1" {
  project                  = var.project_name
  integration_type         = "metrics"
  source_service_name      = aiven_mysql.mysql1.service_name
  destination_service_name = aiven_pg.pg1.service_name
}

resource "aiven_service_integration" "mysql1_to_os1" {
  project                  = var.project_name
  integration_type         = "logs"
  source_service_name      = aiven_mysql.mysql1.service_name
  destination_service_name = aiven_opensearch.os1.service_name
}



output "mysql1_connect"{
  value = aiven_mysql.mysql1.service_uri
  sensitive = true
}

output "mysql1_command"{
  value = format("mysql --host=%s --port=%s --user=%s --password=%s %s",
    aiven_mysql.mysql1.service_host,
    aiven_mysql.mysql1.service_port,
    sensitive(aiven_mysql.mysql1.service_username),
    sensitive(aiven_mysql.mysql1.service_password),
    aiven_mysql_database.mysql1db1.database_name)

  sensitive = true
}

output "mysql1_host_port"{
  value = format("%s:%s", aiven_mysql.mysql1.service_host, aiven_mysql.mysql1.service_port)
}
