resource "azurerm_resource_group" "rg-csr-1" {
  name     = "RG-CSR-1"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet-csr-1" {
  name                = "VNET-CSR-1"
  location            = azurerm_resource_group.rg-csr-1.location
  resource_group_name = azurerm_resource_group.rg-csr-1.name
  address_space       = ["10.241.0.0/16"]
}

resource "azurerm_subnet" "csr-1-sub-outside" {
  name                 = "csr-1-sub-outside"
  virtual_network_name = azurerm_virtual_network.vnet-csr-1.name
  resource_group_name  = azurerm_resource_group.rg-csr-1.name
  address_prefixes     = ["10.241.0.0/24"]
}

resource "azurerm_subnet" "csr-1-sub-inside" {
  name                 = "csr-1-sub-inside"
  virtual_network_name = azurerm_virtual_network.vnet-csr-1.name
  resource_group_name  = azurerm_resource_group.rg-csr-1.name
  address_prefixes     = ["10.241.1.0/24"]
}

resource "azurerm_public_ip" "PIP-1-CSR-1" {
  name                = "PIP-1-csr-1"
  location            = azurerm_resource_group.rg-csr-1.location
  resource_group_name = azurerm_resource_group.rg-csr-1.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "csr-1-nic-1" {
  name                = "csr-1-nic-1"
  location            = azurerm_resource_group.rg-csr-1.location
  resource_group_name = azurerm_resource_group.rg-csr-1.name

  ip_configuration {
    name                          = "csr-1-outside"
    subnet_id                     = azurerm_subnet.csr-1-sub-outside.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PIP-1-CSR-1.id
  }
}

resource "azurerm_network_interface" "csr-1-nic-2" {
  name                 = "csr-1-nic-2"
  location             = azurerm_resource_group.rg-csr-1.location
  resource_group_name  = azurerm_resource_group.rg-csr-1.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "csr-1-inside"
    subnet_id                     = azurerm_subnet.csr-1-sub-inside.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "CSR1" {
  name                = var.csr_hostname
  location            = azurerm_resource_group.rg-csr-1.location
  resource_group_name = azurerm_resource_group.rg-csr-1.name
  size                = "Standard_DS2_v2"

  admin_username        = var.csr_admin_username
  network_interface_ids = [azurerm_network_interface.csr-1-nic-1.id, azurerm_network_interface.csr-1-nic-2.id]
  #zones = ["${count.index}" + 1]

  admin_password                  = var.csr_admin_password
  disable_password_authentication = false
  custom_data = base64encode(templatefile("${path.module}/csr_azure.sh", {
    #     public_conns   = aviatrix_transit_external_device_conn.pubConns
    #     private_conns  = aviatrix_transit_external_device_conn.privConns
    #     pub_conn_keys  = keys(aviatrix_transit_external_device_conn.pubConns)
    #     priv_conn_keys = keys(aviatrix_transit_external_device_conn.privConns)
    #     gateway        = data.aviatrix_transit_gateway.avtx_gateways
    local_ip_outside = azurerm_network_interface.csr-1-nic-1.private_ip_address
    hostname        = var.csr_hostname
    ipsec_peer_list = var.csr_ipsec_peer_list
    asn = var.csr_bgp_local_asn
    peer_asn = var.peer_asn
    loopback_ip = var.csr_loopback_ip
    bgp_peer_list = var.csr_bgp_peer_list
    network_list = var.csr_bgp_adv_prefixes
    
    #     test_client_ip = var.create_client ? azurerm_network_interface.testclient_nic[0].private_ip_address : ""
    #     adv_prefixes   = var.advertised_prefixes
  }))

  plan {
    name      = "17_3_3-byol"
    product   = "cisco-csr-1000v"
    publisher = "cisco"
  }
  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-csr-1000v"
    sku       = "17_3_3-byol"
    version   = "latest"
  }

  os_disk {
    name                 = "csr1-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


}


