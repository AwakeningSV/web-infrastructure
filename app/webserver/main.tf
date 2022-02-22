resource "azurerm_resource_group" "webserver" {
  name     = "${var.prefix}-${var.env}-${terraform.workspace}"
  location = "westus2"
}

resource "azurerm_virtual_network" "webserver" {
  name                = "${var.prefix}-${var.env}-network-${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
}

resource "azurerm_subnet" "webserver_internal" {
  name                 = "${var.prefix}-${var.env}-internal-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.webserver.name
  virtual_network_name = azurerm_virtual_network.webserver.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "webserver" {
  name                = "${var.prefix}-${var.env}-pip-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.webserver.name
  location            = azurerm_resource_group.webserver.location
  allocation_method   = "Static"
  domain_name_label   = "ac-${var.label}-web-${var.env}-${terraform.workspace}"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "webserver" {
  name                = "${var.prefix}-${var.env}-nic-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.webserver.name
  location            = azurerm_resource_group.webserver.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.webserver_internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webserver.id
  }
}

resource "azurerm_network_security_group" "webserver" {
  name                = "${var.prefix}-${var.env}-webserver-nsg-${terraform.workspace}"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = azurerm_network_interface.webserver.private_ip_address
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = azurerm_network_interface.webserver.private_ip_address
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.webserver.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "webserver" {
  network_interface_id      = azurerm_network_interface.webserver.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = "${var.prefix}-${var.env}-vm-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.webserver.name
  location            = azurerm_resource_group.webserver.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.webserver.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_personal_rsa.pub")
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
}
