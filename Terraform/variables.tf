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
