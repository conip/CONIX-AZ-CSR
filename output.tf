output "inside_subnets" {
  value = flatten(azurerm_subnet.csr-1-sub-inside.address_prefixes)
}
