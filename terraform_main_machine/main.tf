resource "azurerm_resource_group" "myterraformgroup" {
	name     = "${var.resource_group_name}"
	location = "${var.location}"
	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_virtual_network" "myterraformnetwork" {
	name                = "${var.virtual_network_name}"
	address_space       = ["${var.virtual_network_address_space}"]
	location            = "${var.location}"
	resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_public_ip" "myterraformpublicip" {
	name                         = "${var.myterraformpublicip_name}"
	location                     = "${var.location}"
	resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
	public_ip_address_allocation = "${var.address_allocation}"

	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_subnet" "myterraformsubnet" {
	name = "${var.myterraformsubnet_name}"
	resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
	virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
	address_prefix = "${var.myterraformsubnet_address_prefix}"
}

resource "azurerm_network_security_group" "myterraformnsg2" {
	name                = "${var.myterraformnsg2_name}"
	location            = "${var.location}"
	resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

	security_rule = [ {
		name = "JENKINS"
		priority = 1002
		direction = "Inbound"
		access = "Allow"
		protocol = "tcp"
		source_port_range = "*"
		destination_port_range = "8080"
		source_address_prefix = "*"
		destination_address_prefix = "*"
	}, {
		name = "SSH"
		priority = 1003
		direction = "Inbound"
		access = "Allow"
		protocol = "tcp"
		source_port_range = "*"
		destination_port_range = "22"
		source_address_prefix = "*"
		destination_address_prefix = "*"
	}, {
		name = "HTTP"
		priority = 1004
		direction = "Inbound"
		access = "Allow"
		protocol = "tcp"
		source_port_range = "*"
		destination_port_range = "80"
		source_address_prefix = "*"
		destination_address_prefix = "*"
	} ]

	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_network_interface" "myterraformnic" {

	name = "${var.myterraformnic_name}"
	location = "${var.location}"
	resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
	network_security_group_id = "${azurerm_network_security_group.myterraformnsg2.id}"

	ip_configuration {
		name = "${var.myterraformnic_ip_configuration}"
		subnet_id = "${azurerm_subnet.myterraformsubnet.id}"
		private_ip_address_allocation = "${var.address_allocation}"
		public_ip_address_id = "${azurerm_public_ip.myterraformpublicip.id}"
	}

	tags {
		environment = "${var.environment}"
	}
}
resource "random_id" "randomId" {
	keepers = {
		# Generate a new ID only when a new resource group is defined
		resource_group = "${azurerm_resource_group.myterraformgroup.name}"
	}

	byte_length = 8
}
resource "azurerm_storage_account" "mystorageaccount" {
	name = "diag${random_id.randomId.hex}"
	resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
	location = "${var.location}"
	account_replication_type = "${var.storage_account_replication_type}"
	account_tier = "${var.storage_account_tiers}"

	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_virtual_machine" "myterraformvm" {
	name = "${var.myterraformfirstvm_name}"
	location = "${var.location}"
	resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
	network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
	vm_size = "${var.virtual_machine_vm_size}"

	storage_os_disk {
		name = "myOsDisk"
		caching = "ReadWrite"
		create_option = "FromImage"
		managed_disk_type = "Premium_LRS"
	}

	storage_image_reference {
		publisher = "Canonical"
		offer = "UbuntuServer"
		sku = "16.04.0-LTS"
		version ="latest"
	}

	os_profile {
		computer_name = "myVM"
		admin_username = "stage"
	}

	os_profile_linux_config {
		disable_password_authentication = "${var.boolean_true}"
		ssh_keys {
			path ="${var.ssh_keys_path}"
			key_data = "${var.ssh_keys_data}"
		}
	}

	boot_diagnostics {
		enabled = "${var.boolean_true}"
		storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
	}

	tags {
		environment = "${var.environment}"
	}
}

