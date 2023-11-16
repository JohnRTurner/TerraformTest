resource "aiven_opensearch" "os-service1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  service_name            = "os-service1"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  opensearch_user_config {
    opensearch_version = "2"
  }
}