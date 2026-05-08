terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  app_port     = var.app_port
}

module "ec2" {
  source             = "./modules/ec2"
  project_name       = var.project_name
  environment        = var.environment
  instance_type      = var.instance_type
  app_port           = var.app_port
  subnet_id          = module.networking.public_subnet_id
  security_group_id  = module.networking.ec2_sg_id
  ssh_public_key     = var.ssh_public_key
  dockerhub_username = var.dockerhub_username
}