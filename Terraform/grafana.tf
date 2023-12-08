resource "aiven_grafana" "grafana1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "startup-1"
  service_name            = "grafana1"
  maintenance_window_dow  = var.maintenance_dow
  maintenance_window_time = var.maintenance_time
  grafana_user_config {
    alerting_enabled = true

    public_access {
      grafana = true
    }
  }
}

resource "aiven_service_integration" "pg1_dashboard_grafana1" {
  project                  = var.project_name
  integration_type         = "dashboard"
  source_service_name      = aiven_grafana.grafana1.service_name
  destination_service_name = aiven_pg.pg1.service_name
}


output "grafana_uri"{ #same as host port
  value = aiven_grafana.grafana1.service_uri
  sensitive = true
}

output "grafana_user_pass"{ #same as host port
  value = format("%s:%s", aiven_grafana.grafana1.service_username, aiven_grafana.grafana1.service_password)
  sensitive = true
}