provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "mi_rg" {
  name     = "mi-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "mi_vnet" {
  name                = "mi-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mi_rg.location
  resource_group_name = azurerm_resource_group.mi_rg.name
}

resource "azurerm_subnet" "mi_subnet" {
  name                 = "mi-subnet"
  resource_group_name  = azurerm_resource_group.mi_rg.name
  virtual_network_name = azurerm_virtual_network.mi_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "mi_nic" {
  name                = "mi-nic"
  location            = azurerm_resource_group.mi_rg.location
  resource_group_name = azurerm_resource_group.mi_rg.name

  ip_configuration {
    name                          = "mi-ip-config"
    subnet_id                     = azurerm_subnet.mi_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "mi_vm" {
  name                  = "mi-vm"
  location              = azurerm_resource_group.mi_rg.location
  resource_group_name   = azurerm_resource_group.mi_rg.name
  network_interface_ids = [azurerm_network_interface.mi_nic.id]

  vm_size = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "mi-vm"
    admin_username = "adminuser"
    admin_password = "Password1234!" # Cambia la contraseña según tus necesidades
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}
