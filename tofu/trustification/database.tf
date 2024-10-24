variable "cluster-vpc-id" {
  type        = string
  description = "The VPC ID of the cluster. Used to connect the RDS instance to the same subnet."
}

data "aws_vpc" "cluster" {
  id = var.cluster-vpc-id
}

data "aws_subnets" "cluster-private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "database-${var.environment}"
  #subnet_ids = data.aws_subnets.cluster-private.ids
  subnet_ids = ["subnet-068f642ae12854fb6", "subnet-019d58d879c0fc1a4"]
}

resource "aws_security_group" "database" {
  name   = "trustification-postgresql-${var.environment}"
  vpc_id = data.aws_vpc.cluster.id
}

resource "aws_security_group_rule" "allow-postgres" {
  protocol          = "TCP"
  security_group_id = aws_security_group.database.id
  from_port         = 5432
  to_port           = 5432
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
#  cidr_blocks       = data.aws_vpc.cluster.cidr_block != "" ? [data.aws_vpc.cluster.cidr_block] : []
#  ipv6_cidr_blocks  = data.aws_vpc.cluster.ipv6_cidr_block != "" ? [data.aws_vpc.cluster.ipv6_cidr_block] : []
}

variable "db-master-user" {
  type        = string
  default     = "postgres"
  description = "Username of the master user of the database"
}

variable "guac-db-admin-password" {
  type = string
  default = "postgres1234"
}

locals {
  # name of the database:
  # > * Must contain 1 to 63 letters, numbers, or underscores.
  # > * Must begin with a letter. Subsequent characters can be letters, underscores, or digits (0-9).
  # > * Can't be a word reserved by the specified database engine
  db-name = "guac_${var.environment}"
}

resource "aws_db_instance" "guac" {
  db_subnet_group_name = aws_db_subnet_group.database.name

  apply_immediately = true

  allocated_storage     = 10
  max_allocated_storage = 100

  db_name             = "guac"
  engine              = "postgres"
  engine_version      = "15.5"
  instance_class      = "db.m7g.large"
  username            = var.db-master-user
  password            = var.guac-db-admin-password
  ca_cert_identifier  = "rds-ca-rsa2048-g1"
  skip_final_snapshot = true

  availability_zone = var.availability-zone
  publicly_accessible = true
}
