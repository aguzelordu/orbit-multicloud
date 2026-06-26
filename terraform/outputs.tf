output "aws_load_balancer_dns" {
  value       = aws_infra.alb_dns_name
  description = "AWS Application Load Balancer DNS Adresi"
}

output "gcp_internal_vm_ip" {
  value       = gcp_infra.vm_private_ip
  description = "GCP Oneri Motoru VM Private IP Adresi"
}