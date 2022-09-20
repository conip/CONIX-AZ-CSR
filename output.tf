output "inside_subnets" {
  value = flatten(azurerm_subnet.csr-1-sub-inside.address_prefixes)
}
output "csr_public_ip" {
  value = azurerm_public_ip.PIP-1-CSR-1.ip_address
}
