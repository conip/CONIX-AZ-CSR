output "csr-1-public-ip" {
  description = "Public IP of created CSR"
  value       = azurerm_public_ip.PIP-1-CSR-1.ip_address
}

output "VNG_primary_public_ip" {
  value = data.terraform_remote_state.ars.outputs.VNG_primary_public_ip
}

output "inside_subnets" {
  value = flatten(azurerm_subnet.csr-1-sub-inside.address_prefixes)
}