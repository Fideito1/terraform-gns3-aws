terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "gns3" {
  name        = "${var.project_name}-sg"
  description = "Security Group para servidor GNS3"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
    description = "GNS3 Server"
    from_port   = 3080
    to_port     = 3080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    description = "Salida a Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
resource "tls_private_key" "gns3_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "gns3_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.gns3_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

resource "local_file" "gns3_private_key" {
  content         = tls_private_key.gns3_key.private_key_openssh
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}
# Obtiene automáticamente la última imagen oficial de Ubuntu 24.04
# publicada por Canonical para AWS.
#
# Se utiliza un data source en lugar de una AMI fija para evitar
# que el código deje de funcionar si AWS cambia el identificador
# de la imagen en el futuro.
data "aws_ami" "ubuntu" {

  # Selecciona la imagen más reciente que cumpla los filtros
  most_recent = true

  # Cuenta oficial de Canonical (Ubuntu) en AWS
  owners = ["099720109477"]

  # Busca imágenes Ubuntu Server 24.04 (Noble Numbat)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  # Solo se aceptan imágenes HVM (Hardware Virtual Machine)
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Instancia EC2 que actuará como servidor GNS3
resource "aws_instance" "gns3_server" {

  # Última imagen oficial de Ubuntu 24.04
  ami = data.aws_ami.ubuntu.id

  # Tipo de instancia definido mediante variable
  instance_type = var.instance_type

  # Despliegue en la subred pública
  subnet_id = aws_subnet.public.id

  # IP privada fija dentro de la VPC
  private_ip = "10.10.1.10"

  # Asociación del Security Group
  vpc_security_group_ids = [
    aws_security_group.gns3.id
  ]

  # Asignación automática de IP pública
  associate_public_ip_address = true

  # Disco raíz del sistema operativo
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-server"
  }
}
# Elastic IP para el servidor GNS3
resource "aws_eip" "gns3_eip" {
  domain   = "vpc"
  instance = aws_instance.gns3_server.id

  tags = {
    Name = "${var.project_name}-eip"
  }
}