
provider "aws" {
  region = var.region
}

resource "aws_security_group" "instance" {
  name = "postgres-security-group"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.11"
  username = "postgres"
  password = "postgres"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.instance.id]
  db_name = "mypostgres"

  tags = {
    Name = "MyPostgresDB"
  }
}
