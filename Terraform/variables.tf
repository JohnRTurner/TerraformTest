variable "aiven_api_token" {
  description = "Aiven console API token"
  type        = string
}

variable "project_name" {
  description = "Aiven console project name"
  type        = string
}

variable "cloud_name" {
  description = "Default Aiven cloud"
  type = string
}

variable "mysql_user" {
  description = "MySQL User Name"
  type = string
}

variable "mysql_password" {
  description = "MySQL Password"
  type = string
}

variable "pg_user" {
  description = "Postgres User Name"
  type = string
}

variable "pg_password" {
  description = "Postgres Password"
  type = string
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key"
  type = string
}

variable "AWS_SESSION_TOKEN" {
  description = "AWS Session Token"
  type = string
}

variable "aws_region" {
  description = "AWS Region"
  type = string
}

variable "dg_instance_name" {
  description = "Name of the instance to be created"
  type = string
  default = "dataGenerator"
}

variable "dg_instance_type" {
  type = string
  #c6i large = 2cpu 4GB memory
  default = "c6i.large"
}

variable "dg_disk_gb" {
  type = number
  default=16
}

variable "dg_ami_id" {
  description = "The AMI to use - Amazon Machine Image (Operating System)"
  type = string
}

variable "dg_sg_id" {
  description = "The Security Group to use"
  type = string
}


variable "dg_number_of_instances" {
  description = "Number of instances to be created"
  type = number
  default = 1
}

variable "dg_key_pair_name" {
  description = "Name of PEM file to be used"
  type = string
}
