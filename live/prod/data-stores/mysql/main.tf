locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "prod-db-creds"
}

provider "aws" {
  region = "us-east-1"
  alias = "primary"
}

provider "aws" {
  region = "ap-south-1"
  alias = "replica"
}

module "mysql_primary" {
  source = "github.com/ottagit/modules//data-stores/mysql?ref=v0.3.7"

  providers = {
    aws = aws.primary
  }

  db_name = "proddb"
  db_username = local.db_creds.username
  db_password = local.db_creds.password
  # Must be enabled to support replication
  backup_retention_period = 1
}

module "mysql_replica" {
  source = "github.com/ottagit/modules//data-stores/mysql?ref=v0.3.7"

  providers = {
    aws = aws.replica
  }

  # Make this a replica of the primary
  replicate_source_db = module.mysql_primary.arn
}

terraform {
  backend "s3" {
    key = "prod/data-stores/mysql/terraform.tfstate"
  }
}