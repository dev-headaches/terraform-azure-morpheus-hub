terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      #version = "~> 2.3.0"
    }
  }
}

data "azurerm_client_config" "current" {}

locals {
  resource_groups = var.resourcegroupnames
}

module "hub_rg" {
  source  = "github.com/dev-headaches/terraform-azurerm-rg"
  #version = "0.0.3"
  resource_groups = local.resource_groups
  prefix    = "rg_hub"
  orgname   = var.orgname
  enviro    = var.enviro
  prjnum    = var.prjnum
  location  = var.location
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = format("%s%s%s%s", "fwp_hub_", var.orgname, var.enviro, var.prjnum)
  resource_group_name = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  location            = var.location
  sku                 = "Premium"
  dns {
    proxy_enabled = "true"
    servers        = ["8.8.8.8"]
  }
  threat_intelligence_mode = "Alert"
  threat_intelligence_allowlist {
  ip_addresses = ["8.8.8.8", "1.1.1.1"]
  fqdns        = ["www.google.com", "saic.com"]
  }

  intrusion_detection {
    mode = "Alert"
  }
}

module "FirewallRuleCollectionGroup" {
  source     = "github.com/dev-headaches/terraform-azurerm-morph_hub_azfw_rcg"
  #version = "0.0.1"
  enviro     = var.enviro
  orgname    = var.orgname
  prjnum     = var.prjnum
  fwp_hub_id = azurerm_firewall_policy.firewall_policy.id
  web_categories_blacklist = var.web_categories_blacklist
  fqdnblacklist     = var.fqdnblacklist
}

module "hub_firewall" {
  source                            = "github.com/dev-headaches/terraform-azurerm-firewall"
  ## Adding new dependencies below to hopefully enforce proper creation order and waiting
  depends_on = [
    azurerm_firewall_policy.firewall_policy,
    module.FirewallRuleCollectionGroup,
    module.azfw_public_ip,
    module.azfw_subnet
  ]
  #version = "0.0.2"
  firewall_name                     = format("%s%s%s%s", "fw_hub_", var.orgname, var.enviro, var.prjnum)
  location                          = var.location
  rgname                            = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  AzureFirewallSubnet_ID            = module.azfw_subnet.subnet_id
  AzureFirewall_Public_IP_ID        = module.azfw_public_ip.public_ip_id
  fwsku                             = "Premium"
  firewall_policy_id                = azurerm_firewall_policy.firewall_policy.id      ## NEW INPUT BECAUSE WE MOVED POLICY OUT
  #enviro                            = var.enviro
  #prjnum                            = var.prjnum
  #orgname                           = var.orgname
  #dns_servers                       = ["8.8.8.8"]
  #ThreatIntelligence_Mode           = "Alert"
  #ThreatIntelligence_IP_Whitelist   = ["8.8.8.8", "1.1.1.1"]
  #ThreatIntelligence_FQDN_Whitelist = ["www.google.com", "kiloroot.com"]
}

module "hub_law" {
  source           = "github.com/dev-headaches/terraform-azurerm-law"
  #version = "0.0.1"
  wsname           = format("%s%s%s%s", "law-hub-", var.orgname, var.enviro, var.prjnum)
  rgname           = lookup(module.hub_rg.rgnames, "Security", "fail")
  location         = var.location
  lawSKU           = "PerGB2018"
  logRetentionDays = 30
}

module "hub_bastion" {
  source                = "github.com/dev-headaches/terraform-azurerm-bastion"
  #version = "0.0.2"
  name                  = "hub"
  enviro                = var.enviro
  orgname               = var.orgname
  prjnum                = var.prjnum
  location              = var.location
  bastionrgname         = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  nsgrgname             = lookup(module.hub_rg.rgnames, "NetSec", "fail")
  AzureBastionSubnet_ID = module.bastion_subnet.subnet_id
  Bastion_Public_IP_ID  = module.bastion_public_ip.public_ip_id
}