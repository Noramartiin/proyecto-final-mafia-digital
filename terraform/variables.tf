# ----------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ----------------------------------------------------------------------------------------------------------------------

variable "app_name" {
  description = "Nombre aplicación"
  type        = string
  default     = "flask-app"
}

variable "aws_region" {
  description = "Región donde desplegamos"
  type        = string
  default     = "us-east-2"
}

variable "aws_access_key" {
  description = "Clave de acceso AWS"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Clave secreta AWS"
  type        = string
  sensitive   = true
}

variable "az_prefix" {
  description = "Zona empleada"
  type        = string
  default     = "us-east"
}

