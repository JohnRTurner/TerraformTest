# Kafka service
resource "aiven_kafka" "kafka1" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  service_name            = "kafka1"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    kafka_connect = true
    kafka_rest    = true
    schema_registry = true
    kafka_version = "3.6"
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

resource "aiven_kafka_connector" "kafka-pg-source" {
  project        = var.project_name
  service_name   = aiven_kafka.kafka1.service_name
  connector_name = "kafka-pg-source"
  config = {
    "database.server.name" = aiven_pg.pg1.service_name
    "database.hostname"    = aiven_pg.pg1.service_host
    "database.port"        = aiven_pg.pg1.service_port
    "database.user"        = aiven_pg.pg1.service_username
    "database.password"    = aiven_pg.pg1.service_password
    "database.dbname"      = aiven_pg_database.pg1db1.database_name
    "database.sslmode" : "require",
    "plugin.name"          = "pgoutput"
    "slot.name"            = "cust_calls_slot"
    "publication.name"     = "cdc_cust_pub"
    "publication.autocreate.mode" = "filtered"
    "tombstones.on.delete" : "true",
    "table.include.list" : "public.customers, public.calls",
    "name" : "kafka-pg-source",
    "connector.class" : "io.debezium.connector.postgresql.PostgresConnector",
    "key.converter" : "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url" : format("https://%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port),
    "key.converter.basic.auth.credentials.source" : "USER_INFO",
    "key.converter.schema.registry.basic.auth.user.info" : format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password),
    "value.converter" : "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url" : format("https://%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port),
    "value.converter.basic.auth.credentials.source" : "USER_INFO",
    "value.converter.schema.registry.basic.auth.user.info" : format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password)
  }
  depends_on = [aiven_kafka.kafka1, aiven_pg_database.pg1db1]
}

resource "aiven_kafka_connector" "kafka-customers-sink" {
  project        = var.project_name
  service_name   = aiven_kafka.kafka1.service_name
  connector_name = "kafka-customers-sink"
  config = {
    "connection.url": format("jdbc:%s", replace(aiven_mysql.mysql1.service_uri,"defaultdb",aiven_mysql_database.mysql1db1.database_name)),
    "insert.mode": "upsert",
    "table.name.format": "customers",
    "pk.mode": "record_key",
    "pk.fields": "customer_id",
    "auto.create": "true",
    "name": "kafka-customers-sink",
    "connector.class": "io.aiven.connect.jdbc.JdbcSinkConnector",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": format("https://%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port),
    "key.converter.basic.auth.credentials.source": "USER_INFO",
    "key.converter.schema.registry.basic.auth.user.info": format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password),
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": format("https://%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port),
    "value.converter.basic.auth.credentials.source": "USER_INFO",
    "value.converter.schema.registry.basic.auth.user.info": format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password),
    "topics": "pg1.public.customers",
    "transforms": "transform-1",
    "transforms.transform-1.delete.handling.mode": "rewrite",
    "transforms.transform-1.drop.tombstones": "false",
    "transforms.transform-1.type": "io.debezium.transforms.ExtractNewRecordState",
  }
  depends_on = [aiven_kafka_connector.kafka-pg-source, aiven_mysql_database.mysql1db1]
}

resource "aiven_kafka_connector" "kafka-calls-sink" {
  project        = var.project_name
  service_name   = aiven_kafka.kafka1.service_name
  connector_name = "kafka-calls-sink"
  config = {
    "connection.url": format("jdbc:%s", replace(aiven_mysql.mysql1.service_uri,"defaultdb",aiven_mysql_database.mysql1db1.database_name)),
    "insert.mode": "upsert",
    "table.name.format": "calls",
    "pk.mode": "record_key",
    "pk.fields": "call_id",
    "auto.create": "true",
    "name": "kafka-calls-sink",
    "connector.class": "io.aiven.connect.jdbc.JdbcSinkConnector",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": format("https://%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port),
    "key.converter.basic.auth.credentials.source": "USER_INFO",
    "key.converter.schema.registry.basic.auth.user.info": format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password),
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": format("https://%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port),
    "value.converter.basic.auth.credentials.source": "USER_INFO",
    "value.converter.schema.registry.basic.auth.user.info": format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password),
    "topics": "pg1.public.calls",
    "transforms": "transform-1,transform-2",
    "transforms.transform-1.delete.handling.mode": "rewrite",
    "transforms.transform-1.drop.tombstones": "false",
    "transforms.transform-1.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.transform-2.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
    "transforms.transform-2.target.type": "Timestamp",
    "transforms.transform-2.field": "call_date",
    "transforms.transform-2.unix.precision": "milliseconds"
  }
  depends_on = [aiven_kafka_connector.kafka-pg-source, aiven_mysql_database.mysql1db1]
}


output "kafka1_service_uri"{ #same as host port
  value = aiven_kafka.kafka1.service_uri
  sensitive = true
}


output "kafka1_schema_uri"{
  value = format("%s:%s", aiven_kafka.kafka1.components[2].host, aiven_kafka.kafka1.components[2].port)
}

output "kafka1_user_pass"{
  value = format("%s:%s", aiven_kafka.kafka1.service_username, aiven_kafka.kafka1.service_password)
  sensitive = true
}