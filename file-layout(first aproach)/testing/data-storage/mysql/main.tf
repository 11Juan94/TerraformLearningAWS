terraform {
  backend "s3" {
      bucket = "private-terraform-state-test"
      key = "testing/data-storage/mysql/terraform.tfstate"
      region = "us-east-2"

      dynamodb_table = "private-terraform-locks-test"
      encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "db_instance_test" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  db_name = "example_database"

  username = "admin"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}

data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = "testing/mysql-dbpass"
}

output "address" {
  value = aws_db_instance.db_instance_test.address
  description = "Connect with the DB at this endpoint"
}

output "port" {
  value = aws_db_instance.db_instance_test.port
  description = "The port the database is listening on"
}