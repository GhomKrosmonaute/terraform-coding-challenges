variable "region" {
  default = "ap-northeast-1"
    type = string
}

variable "pg_database_name" {
    default = "postgres"
  type = string
}

variable "pg_database_user" {
    default = "postgres"
  type = string
}

variable "pg_database_password" {
    default = "postgres"
  type = string
}

variable "pg_database_instance_class" {
    default = "db.t2.micro"
  type = string
}