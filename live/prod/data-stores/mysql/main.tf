provider "aws" {
  region = "us-east-1"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "prod-db-creds"
}

resource "aws_db_instance" "prod" {
  identifier_prefix = "prod-db"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.m5.large"
  skip_final_snapshot = true
  db_name = "proddb"

  # Set prod DB username and password
  username = local.db_creds.username
  password = local.db_creds.password
}

terraform {
  backend "s3" {
    key = "prod/data-stores/mysql/terraform.tfstate"
  }
}