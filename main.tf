terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp"
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

module "hub_firewall" {
  source                            = "github.com/dev-headaches/terraform-azurerm-firewall"
  #version = "0.0.2"
  firewall_name                     = format("%s%s%s%s", "fw_hub_", var.orgname, var.enviro, var.prjnum)
  enviro                            = var.enviro
  fwsku                             = "Premium"
  prjnum                            = var.prjnum
  orgname                           = var.orgname
  location                          = var.location
  rgname                            = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
  AzureFirewall_Public_IP_ID        = module.azfw_public_ip.public_ip_id
  AzureFirewallSubnet_ID            = module.azfw_subnet.subnet_id
  dns_servers                       = ["8.8.8.8"]
  ThreatIntelligence_Mode           = "Alert"
  ThreatIntelligence_IP_Whitelist   = ["8.8.8.8", "1.1.1.1"]
  ThreatIntelligence_FQDN_Whitelist = ["www.google.com", "kiloroot.com"]
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

module "FirewallRuleCollectionGroup" {
  source     = "github.com/dev-headaches/terraform-azurerm-morph_hub_azfw_rcg"
  #version = "0.0.1"
  enviro     = var.enviro
  orgname    = var.orgname
  prjnum     = var.prjnum
  fwp_hub_id = module.hub_firewall.fwp_id
  web_categories_blacklist = var.web_categories_blacklist
  fqdnblacklist     = var.fqdnblacklist
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