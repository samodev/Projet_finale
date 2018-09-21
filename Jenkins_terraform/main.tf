

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.nom_resource}"
    location = "${var.location_world}"
    tags {
        environment = "${var.environment_name}"
    }
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "${var.network_name}"
    address_space       = ["${var.address_space_number}"]
    location            = "${var.location_world}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "${var.environment_name}"
    }
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "${var.subnet}"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip1" {
    count                        = "${length(var.ip_addresses)}"
    name                         = "${var.publicIP}${count.index}"
    location                     = "${var.location_world}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation_name}"

    tags {
        environment = "${var.environment_name}"
    }
}


resource "azurerm_network_security_group" "myterraformnsg1" {
    name                = "${var.NetworkSecurityGroup}"
    location            = "${var.location_world}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    
    tags {
        environment = "${var.environment_name}"
    }
security_rule {
        name                       = "${var.security_rule}"
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


resource "azurerm_network_interface" "myterraformnic1" {

    count               = "${length(var.ip_addresses)}"
    name                = "${var.NetworkInterface}${count.index}"
    location            = "${var.location_world}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "${var.NicConfiguration}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "${element(var.ip_addresses, count.index)}"
        ##public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip1.*.id, count.index)}"

    }

    tags {
        environment = "${var.environment_name}"
    }
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg1.id}"
}


resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}


resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    location            = "${var.location_world}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "${var.environment_name}"
    }
}

resource "azurerm_virtual_machine" "myterraformvm1" {
    count                 = "${length(var.ip_addresses)}"
    name                  = "${var.name_virtual_machine}${count.index}"
    location              = "${var.location_world}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic1.*.id, count.index)}"]

    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "${var.storage_disk}${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }


    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm1${count.index}"
        admin_username = "stage"
    }


    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "${var.ssh_keys_path}"
            key_data = "${var.ssh_keys_data}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "${var.environment_name}"
    }
}
####  CINQUIEME MACHINE

resource "azurerm_resource_group" "myterraformgroup5" {
    name     = "${var.nom_resource5}"
    location = "${var.location_world5}"
    tags {
        environment = "${var.environment_name5}"
    }
}

resource "azurerm_virtual_network" "myterraformnetwork5" {
    name                = "${var.network_name5}"
    address_space       = ["${var.address_space_number5}"]
    location            = "${var.location_world5}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup5.name}"

    tags {
        environment = "${var.environment_name5}"
    }
}

resource "azurerm_subnet" "myterraformsubnet5" {
    name = "${var.subnet5}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup5.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork5.name}"
    address_prefix = "10.0.2.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip5" {
    name                         = "${var.publicIP5}"
    location                     = "${var.location_world5}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation_name5}"

    tags {
        environment = "${var.environment_name5}"
    }
}

resource "azurerm_network_security_group" "myterraformnsg5" {
    name = "${var.NetworkSecurityGroup5}"
    location = "${var.location_world5}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup5.name}"


    tags {
        environment = "${var.environment_name5}"
    }

    security_rule {
        name                       = "${var.security_rule}"
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
resource "azurerm_network_interface" "myterraformnic5" {
    name                = "${var.NetworkInterface5}"
    location            = "${var.location_world5}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup5.name}"

    ip_configuration {
        name                          = "${var.NicConfiguration5}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet5.id}"
        private_ip_address_allocation = "static"
        private_ip_address            = "${var.ip_addresses5}"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip5.id}"

    }

    tags {
        environment = "${var.environment_name5}"
    }
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg5.id}"
}

resource "random_id" "randomId5" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup5.name}"
    }

    byte_length = 8
}




resource "azurerm_storage_account" "mystorageaccount5" {
    name                = "diag${random_id.randomId5.hex}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup5.name}"
    location            = "${var.location_world5}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "${var.environment_name5}"
    }
}

resource "azurerm_virtual_machine" "myterraformvm5" {
    name                  = "${var.name_virtual_machine5}"
    location              = "${var.location_world5}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup5.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic5.id}"]

    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "${var.storage_disk5}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }


    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm5"
        admin_username = "stage"
    }


    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "${var.ssh_keys_path}"
            key_data = "${var.ssh_keys_data}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "${var.environment_name5}"
    }
}
