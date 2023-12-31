resource "aws_instance" "data-generator" {
  ami = var.dg_ami_id
  count = var.dg_number_of_instances
  #subnet_id = var.dg_subnet_id
  instance_type = var.dg_instance_type
  ebs_optimized = true
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
    encrypted = false
    volume_size = var.dg_disk_gb
    volume_type = "gp2"
  }
  security_groups = [var.dg_sg_id]
  key_name = var.dg_key_pair_name
  user_data = templatefile("dataGenerator.tftpl",
    {
      PGPASSWORD=aiven_pg.pg1.service_password,
      PGHOST=aiven_pg.pg1.service_host,
      PGPORT=aiven_pg.pg1.service_port,
      PGUSER=aiven_pg.pg1.service_username,
      PGDATABASE=aiven_pg_database.pg1db1.database_name
    }
  )
  tags = {
    Name = format("%s-%02d",var.dg_instance_name, count.index + 1)
  }
  timeouts {
    delete = "15m"
    update = "15m"
    create = "15m"
  }
  depends_on = [aiven_kafka_connector.kafka-calls-sink, aiven_kafka_connector.kafka-customers-sink]
}

output "dataGeneratorName"{
  value = [aws_instance.data-generator.*.tags.Name]
}

output "dataGeneratorIP"{
  value = [aws_instance.data-generator.*.public_ip]
}

output "dataGeneratorDNS"{
  value = [aws_instance.data-generator.*.public_dns]
}
