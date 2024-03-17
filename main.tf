
provider "aws" {
  region = var.region
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["postech-vpc"]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:kubernetes.io/cluster/education-eks-cluster"
    values = ["shared"]
  }
}

resource "aws_security_group" "instance" {
  name   = "postgres-security-group"
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "education" {
  identifier          = "education"
  instance_class      = "db.t3.micro"
  allocated_storage   = 5
  engine              = "postgres"
  engine_version      = "14.11"
  username            = "postgres"
  password            = "postgres"
  publicly_accessible = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = data.aws_subnet.selected.id

  db_name = "mypostgres"

  tags = {
    Name = "MyPostgresDB"
  }
}
