variable "aws_region" {
  description = "Región de AWS donde se desplegará el laboratorio"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "gns3-lab"
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango CIDR de la subred pública"
  type        = string
  default     = "10.10.1.0/24"
}
variable "allowed_ip" {
  description = "IP pública autorizada para conectarse por SSH y GNS3"
  type        = string
  default     = "0.0.0.0/0"
}
variable "instance_type" {
  description = "Tipo de instancia EC2 para el servidor GNS3"
  type        = string
  default     = "t3.medium"
}