# variables.tf
# Variáveis do projeto - permite reutilizar o código com outros valores

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Nome usado como prefixo em todos os recursos"
  type        = string
  default     = "capacita-irede"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Bloco CIDR da subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome do Key Pair da EC2 já existente na sua conta AWS (para SSH)"
  type        = string
}
