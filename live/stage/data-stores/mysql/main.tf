# Create the DB resources
provider "aws" {
  region = "us-east-1"
}

locals {
  db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}

data "aws_kms_secrets" "creds" {
  secret {
    name = "db"
    payload = file("${path.module}/db-creds.yml.encrypted")
  }
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