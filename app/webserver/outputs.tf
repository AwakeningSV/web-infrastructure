output "fqdn" {
  description = "Public DNS FQDN"
  value       = "${azurerm_public_ip.webserver.domain_name_label}.${var.region}.cloudapp.azure.com"
  sensitive   = true
}