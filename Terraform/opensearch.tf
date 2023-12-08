resource "aiven_opensearch" "os1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "startup-4"
  service_name            = "os1"
  maintenance_window_dow  = var.maintenance_dow
  maintenance_window_time = var.maintenance_time

  opensearch_user_config {
    opensearch_version = 2

    opensearch_dashboards {
      enabled                    = true
      opensearch_request_timeout = 30000
    }

    public_access {
      opensearch            = true
      opensearch_dashboards = true
    }
  }
  provisioner "local-exec" {
    command = format("curl -X PUT %s/calls_2023-12", aiven_opensearch.os1.service_uri)
  }
}

resource "aiven_service_integration" "os1_to_pg1" {
  project                  = var.project_name
  integration_type         = "metrics"
  source_service_name      = aiven_opensearch.os1.service_name
  destination_service_name = aiven_pg.pg1.service_name
}

resource "aiven_service_integration" "os1_to_os1" {
  project                  = var.project_name
  integration_type         = "logs"
  source_service_name      = aiven_opensearch.os1.service_name
  destination_service_name = aiven_opensearch.os1.service_name
}


output "os1_connect"{
  value = aiven_opensearch.os1.service_uri
  sensitive = true
}

output "os1_host_port"{
  value = format("%s:%s", aiven_opensearch.os1.service_host, aiven_opensearch.os1.service_port)
}
