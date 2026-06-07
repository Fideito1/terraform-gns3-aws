variable "aws_region" {
  description = "Región de AWS donde se desplegará el laboratorio"
  type        = string
  default     = "us-east-1"
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

variable "private_subnet_cidr" {
  description = "Rango CIDR de la subred privada para laboratorios"
  type        = string
  default     = "10.10.2.0/24"
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

variable "root_volume_size" {
  description = "Tamaño del disco raíz"
  type        = number
  default     = 30
}

variable "allocate_elastic_ip" {
  description = "Asignar Elastic IP al servidor GNS3"
  type        = bool
  default     = true
}

variable "ebs_size" {
  description = "Tamaño del volumen EBS para GNS3"
  type        = number
  default     = 100
}

variable "create_sri_labs" {
  description = "Crear escenario SRI en la subred privada"
  type        = bool
  default     = true
}

variable "sri_lab_instance_type" {
  description = "Tipo de instancia para los laboratorios SRI"
  type        = string
  default     = "t3.micro"
}
