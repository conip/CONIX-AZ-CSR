output "csr_private_ip" {
  value = azurerm_network_interface.csr-1-nic-1.private_ip_addresses
}
output "csr_public_ip" {
  value = azurerm_public_ip.PIP-1-CSR-1.ip_address
}
