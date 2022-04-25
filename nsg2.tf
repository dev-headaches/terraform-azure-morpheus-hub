module "NSG_VM" {
  source    = "github.com/dev-headaches/terraform-azurerm-NSG"
  #version = "0.0.3"
  nsgname   = format("%s%s%s%s", "nsg_vm_snet", var.orgname, var.enviro, var.prjnum)
  location  = var.location
  rgname    = lookup(module.hub_rg.rgnames, "NetSec", "fail")
  subnet_id = module.vm_subnet.subnet_id
}

####

module "NSG_INT_RULE_ALLOW-TO-INTERNET-OUTBOUND" {
  source                   = "github.com/dev-headaches/terraform-azurerm-nsgrule2"
  #version = "0.0.1"
  name                     = "ALLOW-TO-INTERNET-OUTBOUND"
  priority                 = 3800
  direction                = "Outbound"
  access                   = "Allow"
  protocol                 = "*"
  sourcePortRange          = "*"
  destinationPortRanges    = ["443", "80"]
  sourceAddressPrefix      = "VirtualNetwork"
  destinationAddressPrefix = "Internet"
  resourceGroupName        = lookup(module.hub_rg.rgnames, "NetSec", "fail")
  networkSecurityGroupName = module.NSG_VM.nsg_name
}