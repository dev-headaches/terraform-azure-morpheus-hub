module "vnet_hub" {
  source   = "app.terraform.io/roman2025/vnet/azurerm"
  version = "0.0.1"
  enviro   = var.enviro
  name     =  "hub"
  prjnum   = var.prjnum
  location = var.location
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  orgname  = var.orgname
  address_space = var.vnet_hub_address_spaces
  dns_servers = var.vnet_hub_dns_servers
}

module "bastion_public_ip" {
  source   = "app.terraform.io/roman2025/pip/azurerm"
  version = "0.0.2"
  enviro   = var.enviro
  name     = "bast"
  prjnum   = var.prjnum
  location = var.location
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  orgname  = var.orgname
  allocation_method = "Static"
  sku      = "Standard"
}

module "azfw_subnet" {
  source   = "app.terraform.io/roman2025/subnet/azurerm"
  version = "0.0.1"
  name     = "AzureFirewallSubnet"
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  virtual_network_name = module.vnet_hub.vnet_name
  address_prefixes      = var.azfw_subnet_prefixes
  service_endpoints = []
}

module "bastion_subnet" {
  source   = "app.terraform.io/roman2025/subnet/azurerm"
  version = "0.0.1"
  name     = "AzureBastionSubnet"
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  virtual_network_name = module.vnet_hub.vnet_name
  address_prefixes      = var.bastion_subnet_prefixes
  service_endpoints = []
}

module "gateway_subnet" {
  source   = "app.terraform.io/roman2025/subnet/azurerm"
  version = "0.0.1"
  name     = "GatewaySubnet"
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  virtual_network_name = module.vnet_hub.vnet_name
  address_prefixes      = var.gateway_subnet_prefixes
  service_endpoints = []
}

module "vm_subnet" {
  source   = "app.terraform.io/roman2025/subnet/azurerm"
  version = "0.0.1"
  name     = "snet_vm"
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  virtual_network_name = module.vnet_hub.vnet_name
  address_prefixes      = var.vm_subnet_prefixes
  service_endpoints = []
}

module "azfw_public_ip" {
  source   = "app.terraform.io/roman2025/pip/azurerm"
  version = "0.0.2"
  enviro   = var.enviro
  name     = "azfw"
  prjnum   = var.prjnum
  location = var.location
  rgname   = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  orgname  = var.orgname
  allocation_method = "Static"
  sku      = "Standard"
}

module "azfw_hub_gateway_routetable" {
  source           = "app.terraform.io/roman2025/routetable/azurerm"
  version = "0.0.1"
  tablename        = format("%s%s%s%s%s", "rt_table_snet_hub_gateway", var.orgname, var.enviro, "_", var.prjnum)
  location         = var.location
  rgname           = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  AssocSubnet_id   = module.gateway_subnet.subnet_id
  disable_bgp_rt_prop = false
}

module "azfw_hub_gateway_route" {
  source                         = "app.terraform.io/roman2025/route/azurerm"
  version = "0.0.1"
  routename                      = format("%s%s%s%s%s", "rt_azfw_default_", var.orgname, var.enviro, "_", var.prjnum)
  rgname                         = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  address_prefix                 = "192.168.50.0/24"
  next_hop_type                  = "VirtualAppliance"
  next_hop_ip_address            = module.hub_firewall.fw_private_ip_address
  rt_table_name                  = module.azfw_hub_gateway_routetable.rt_table_name
}

module "routetable_snet_vm" {
  source              = "app.terraform.io/roman2025/routetable/azurerm"
  version = "0.0.1"
  tablename           = format("%s%s%s%s%s", "rt_table_snet_vm_", var.orgname, var.enviro, "_", var.prjnum)
  location            = var.location
  rgname              = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  AssocSubnet_id      = module.vm_subnet.subnet_id
  disable_bgp_rt_prop = true
}

module "route_azfw_default_from_snet_vm" {
  source              = "app.terraform.io/roman2025/route/azurerm"
  version = "0.0.1"
  routename           = format("%s%s%s%s%s", "rt_azfw_default_from_snet_vm_", var.orgname, var.enviro, "_", var.prjnum)
  rgname              = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  next_hop_ip_address = module.hub_firewall.fw_private_ip_address
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  rt_table_name       = module.routetable_snet_vm.rt_table_name
}