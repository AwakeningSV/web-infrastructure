resource "azurerm_resource_group" "web_staging" {
  name     = "${var.prefix}-staging-${terraform.workspace}"
  location = "westus2"
}

resource "azurerm_virtual_network" "web_staging" {
  name                = "${var.prefix}-staging-network-${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.web_staging.location
  resource_group_name = azurerm_resource_group.web_staging.name
}

resource "azurerm_subnet" "web_staging_internal" {
  name                 = "${var.prefix}-staging-internal-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.web_staging.name
  virtual_network_name = azurerm_virtual_network.web_staging.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "web_staging" {
  name                = "${var.prefix}-pip-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.web_staging.name
  location            = azurerm_resource_group.web_staging.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.label}-web-staging-${terraform.workspace}"
}

resource "azurerm_network_interface" "web_staging" {
  name                = "${var.prefix}-nic-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.web_staging.name
  location            = azurerm_resource_group.web_staging.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_staging_internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_staging.id
  }
}

resource "azurerm_network_security_group" "web_staging" {
  name                = "${var.prefix}-staging-webserver-nsg-${terraform.workspace}"
  location            = azurerm_resource_group.web_staging.location
  resource_group_name = azurerm_resource_group.web_staging.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = azurerm_network_interface.web_staging.private_ip_address
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
    destination_address_prefix = azurerm_network_interface.web_staging.private_ip_address
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
    destination_address_prefix = azurerm_network_interface.web_staging.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "web_staging" {
  network_interface_id      = azurerm_network_interface.web_staging.id
  network_security_group_id = azurerm_network_security_group.web_staging.id
}

resource "azurerm_linux_virtual_machine" "web_staging" {
  name                = "${var.prefix}-staging-vm-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.web_staging.name
  location            = azurerm_resource_group.web_staging.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.web_staging.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_personal_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
}