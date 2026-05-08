variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "instance_type"      { type = string }
variable "app_port"           { type = number }
variable "subnet_id"          { type = string }
variable "security_group_id"  { type = string }
variable "ssh_public_key"     { type = string }
variable "dockerhub_username" { type = string }