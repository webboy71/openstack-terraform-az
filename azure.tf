resource "random_pet" "rg_name" {
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg-${random_pet.rg_name.id}"
}

# Create virtual network
resource "azurerm_virtual_network" "openstack_network" {
  name                = "osVnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "openstack_subnet" {
  name                 = "osSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.openstack_network.name
  address_prefixes     = ["10.1.0.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "openstack_public_ip" {
  name                = "osPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "openstack_nsg" {
  name                = "osNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "openstack_nic" {
  name                = "osNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "os_nic_configuration"
    subnet_id                     = azurerm_subnet.openstack_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.openstack_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "openstack_nic_nsg" {
  network_interface_id      = azurerm_network_interface.openstack_nic.id
  network_security_group_id = azurerm_network_security_group.openstack_nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "openstack_storage_account" {
#  name                     = "diag${random_id.random_id.hex}"
# location                 = azurerm_resource_group.rg.location
#  resource_group_name      = azurerm_resource_group.rg.name
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "openstack_ubuntu" {
  name                  = "openstack-ubuntu"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.openstack_nic.id]
  size                  = "Standard_D4s_v4"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "cloud-infrastructure-services"
    offer     = "ubuntu-minimal-24-04"
    sku       = "ubuntu-minimal-24-04"
    version   = "latest"
  }

  plan {
    name      = "ubuntu-minimal-24-04"
    publisher = "cloud-infrastructure-services"
    product   = "ubuntu-minimal-24-04"
  }

  computer_name  = "openstack-ubuntu"
  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path) # Path to your public key
    #public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  #  boot_diagnostics {
  #    storage_account_uri = azurerm_storage_account.os_storage_account.primary_blob_endpoint
  #  }
}