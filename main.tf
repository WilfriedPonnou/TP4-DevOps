resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  resource_group_name = data.azurerm_resource_group.tp4.name
  location            = data.azurerm_resource_group.tp4.location
  allocation_method   = "Dynamic"
}
resource "tls_private_key" "example_ssh"{
    algorithm="RSA"
    rsa_bits=4096
}

resource "azurerm_network_interface" "tp4" {
  name                = "example-nic"
  location            = data.azurerm_resource_group.tp4.location
  resource_group_name = data.azurerm_resource_group.tp4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.tp4.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "tp4" {
  name                = "devops-20201252"
  resource_group_name = data.azurerm_resource_group.tp4.name
  location            = data.azurerm_resource_group.tp4.location
  size                = "Standard_D2s_v3"
  admin_username      = "devops"
  network_interface_ids = [
    azurerm_network_interface.tp4.id,
  ]

  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
output "tls_private_key" {
  value = tls_private_key.example_ssh.private_key_pem
  sensitive=true
}