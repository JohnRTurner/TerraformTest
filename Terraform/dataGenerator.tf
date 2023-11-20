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
  user_data = file("out/localbuild.sh")
  tags = {
    Name = format("%s-%02d",var.dg_instance_name, count.index + 1)
  }
  timeouts {
    delete = "15m"
    update = "15m"
    create = "15m"
  }
  depends_on = [aiven_kafka_connector.kafka-pg-source]
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
