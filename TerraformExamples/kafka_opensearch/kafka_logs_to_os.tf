# Kafka connect service
resource "aiven_kafka_connect" "logs-connector" {
  depends_on = [aiven_kafka.kafka1, aiven_opensearch.os-service1]
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  service_name            = "kafka-connect-logs-connector"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  kafka_connect_user_config {
    kafka_connect {
      consumer_isolation_level = "read_committed"
    }
    public_access {
      kafka_connect = true
    }
  }
}

# Kafka connect service integration
resource "aiven_service_integration" "kafka-to-logs-connector" {
  depends_on = [aiven_kafka_connect.logs-connector]
  project                  = var.project_name
  integration_type         = "kafka_connect"
  source_service_name      = aiven_kafka.kafka1.service_name
  destination_service_name = aiven_kafka_connect.logs-connector.service_name
  kafka_connect_user_config {
    kafka_connect {
      group_id             = "connect"
      status_storage_topic = "__connect_status"
      offset_storage_topic = "__connect_offsets"
    }
  }
}

# Kafka connect service integration
resource "aiven_service_integration" "logs-to-os-connector" {
  depends_on = [aiven_kafka_connect.logs-connector]
  project                  = var.project_name
  integration_type         = "logs"
  source_service_name      = aiven_kafka_connect.logs-connector.service_name
  destination_service_name = aiven_opensearch.os-service1.service_name
  logs_user_config {
    elasticsearch_index_days_max = 3
    elasticsearch_index_prefix   = "kafka-logs"
  }
}
