variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Used as a prefix for all resource names"
  type        = string
  default     = "deploy-prod-ready-application"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "app_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "dockerhub_username" {
  description = "sangdevsecops"
  type        = string
}

variable "ssh_public_key" {
  description = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZ1N+dzP+BJycpKdFjCikWCt0BwdiPxZfjryOqiDEUA deploy-ec2-access"
  type        = string
}