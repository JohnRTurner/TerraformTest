# Kafka service
resource "aiven_kafka" "kafka1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  service_name            = "kafka1"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    kafka_connect = false
    kafka_rest    = true
    schema_registry = true
    kafka_version = "3.5"
    kafka {
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
      auto_create_topics_enable  = true
      num_partitions             = 3
      default_replication_factor = 2
      min_insync_replicas        = 2
    }
    kafka_authentication_methods {
      certificate = true
    }
  }
}

resource "aiven_kafka_connect" "demo-kafka-connect" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  #project_vpc_id          = "PROJECT_NAME/ABCD1234-AB12-AB12-AB12-ABCDEF123456"
  plan                    = "startup-4"
  service_name            = "demo-kafka-connect"
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

resource "aiven_service_integration" "i1" {
  project                  = var.project_name
  integration_type         = "kafka_connect"
  source_service_name      = aiven_kafka.kafka1.service_name
  destination_service_name = aiven_kafka_connect.demo-kafka-connect.service_name

  kafka_connect_user_config {
    kafka_connect {
      group_id             = "connect"
      status_storage_topic = "__connect_status"
      offset_storage_topic = "__connect_offsets"
    }
  }
}

