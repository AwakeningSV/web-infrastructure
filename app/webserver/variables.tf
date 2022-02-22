variable "env" {
  description = "Environment name"
  type        = string
}

variable "prefix" {
  description = "Prefix for app resources"
  type        = string
}

variable "label" {
  description = "Label inside public DNS names"
  type        = string
  sensitive   = true
}

variable "region" {
  type = string
}
