
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

data "aws_security_group" "g35_sg" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name        = "g35_sg"
  }
}

resource "aws_db_subnet_group" "pedido" {
  name       = "pedido"
  subnet_ids = data.aws_subnet_ids.example.ids

  tags = {
    Name = "Pedido"
  }
}

resource "aws_db_instance" "pedido" {
  identifier             = "pedido"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.11"
  username               = "postgres"
  password               = "postgres"
  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.pedido.name
  vpc_security_group_ids = ["${data.aws_security_group.g35_sg.ids}"]
  tags = {
    Name = "PedidoPostgresDB"
  }
}
