
provider "aws" {
  region = var.region
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["g35-vpc"]
  }
}

data "aws_subnet_ids" "example" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.example.ids
  id       = each.value
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.example : s.cidr_block]
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

resource "aws_db_subnet_group" "medico" {
  name       = "medico"
  subnet_ids = data.aws_subnet_ids.example.ids

  tags = {
    Name = "medico"
  }
}

resource "aws_db_instance" "medico" {
  identifier             = "medico"
  name                   = "medico"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.11"
  username               = "postgres"
  password               = "postgres"
  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.medico.name
  vpc_security_group_ids = [aws_security_group.instance.id]
  tags = {
    Name = "MedicoPostgresDB"
  }
}
