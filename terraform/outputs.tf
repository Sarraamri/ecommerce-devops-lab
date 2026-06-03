# =====================================================================
# Outputs consumed by the GitHub Actions pipeline to build the Ansible
# inventory (private IPs reached through the bastion) and to print the URL.
# =====================================================================

output "instance_private_ips" {
  description = "Private IPs of the app instances (Ansible targets, via bastion)"
  value       = aws_instance.web[*].private_ip
}

output "bastion_public_ip" {
  description = "Public IP of the bastion/jump host"
  value       = aws_instance.bastion.public_ip
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB - open this in your browser"
  value       = aws_lb.web.dns_name
}
