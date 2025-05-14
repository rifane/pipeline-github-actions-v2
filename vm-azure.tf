resource "azurerm_resource_group" "rg" {
  name     = "rg-vm"
  location = "West Europe"

  tags = local.common_tags
}

resource "azurerm_public_ip" "ip" {
  name                = "public-ip-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = local.common_tags
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public-ip-terraform"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }

  tags = local.common_tags

}

resource "azurerm_network_interface_security_group_association" "nisga" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.security_group_id

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = "terraform"
  # admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "terraform"
    public_key = var.azure_key_pub
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # source_image_reference {
  #   publisher = "canonical"
  #   # offer     = "UbuntuServer"
  #   offer   = "0001-com-ubuntu-server-jammy"
  #   sku     = "22.04-lts"
  #   version = "latest"
  # }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202504250"
  }

  tags = local.common_tags

}