# Create the DB resources
provider "aws" {
  region = "us-east-1"
}

# Since the secret is stored as JSON, use the jsonencode
# function to parse the JSON into the local variable db_creds
locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

# Read the db-creds secret
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraone"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "terraone_db"

  # Set master DB username and password
  username = local.db_creds.username
  password = local.db_creds.password
}

terraform {
  backend "s3" {
    key = "stage/data-stores/mysql/terraform.tfstate"
  }
}