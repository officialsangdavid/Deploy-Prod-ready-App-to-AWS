output "ec2_public_ip" {
  description = "Public IP — this will be used to access the app and Grafana"
  value       = module.ec2.public_ip
}

output "app_url" {
  value = "http://${module.ec2.public_ip}"
}

output "grafana_url" {
  value = "http://${module.ec2.public_ip}:3001"
}

output "prometheus_url" {
  value = "http://${module.ec2.public_ip}:9090"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/deploy-prod-ready-app ec2-user@${module.ec2.public_ip}"
}