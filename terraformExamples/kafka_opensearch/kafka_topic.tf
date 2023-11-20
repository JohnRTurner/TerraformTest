# Kafka topic
resource "aiven_kafka_topic" "topic-logs-app-1" {
  depends_on = [aiven_kafka.kafka1]
  project      = var.project_name
  service_name = aiven_kafka.kafka1.service_name
  topic_name   = "logs-app-1"
  partitions   = 3
  replication  = 2
}

# Kafka send topic to OpenSearch
resource "aiven_kafka_connector" "kafka-os-con1" {
  depends_on = [aiven_kafka_topic.topic-logs-app-1, aiven_opensearch.os-service1]
  project        = var.project_name
  service_name   = aiven_kafka.kafka1.service_name
  connector_name = "kafka-os-con1"
  config = {
    "topics"                         = aiven_kafka_topic.topic-logs-app-1.topic_name
    "connector.class"                = "io.aiven.kafka.connect.opensearch.OpensearchSinkConnector"
    "type.name"                      = "os-connector"
    "name"                           = "kafka-os-con1"
    "connection.url"                 = "https://${aiven_opensearch.os-service1.service_host}:${aiven_opensearch.os-service1.service_port}"
    "connection.username"            = sensitive(aiven_opensearch.os-service1.service_username)
    "connection.password"            = sensitive(aiven_opensearch.os-service1.service_password)
    "key.converter"                  = "org.apache.kafka.connect.storage.StringConverter"
    "value.converter"                = "org.apache.kafka.connect.json.JsonConverter"
    "tasks.max"                      = 1
    "schema.ignore"                  = true
    "value.converter.schemas.enable" = false
  }
  provisioner "local-exec" {
    command = "echo first >> john.out"
  }
  provisioner "local-exec" {
    command = "echo second  >> john.out"
  }
}
