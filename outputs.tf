output "fw_hub_private_ip_address" {
  value = module.hub_firewall.fw_private_ip_address
}

output "vnet_hub_id" {
  value       = module.vnet_hub.vnet_id
  description = "the id of the primary virtual network"
}

output "fwp_hub_id" {
  value       = module.hub_firewall.fwp_id
  description = "the resource id of the hub firewall policy"
}

output "vnet_hub_name" {
  value       = module.vnet_hub.vnet_name
  description = "the name of the primary virtual network"
}

output "hub_connectivity_rg_name" {
  value = lookup(module.hub_rg.rgnames, "Connectivity", "fail")
}

output "AzureBastionSubnet_address_prefixes" {
  value       = module.bastion_subnet.address_prefixes
  description = "the subnet prefix of the AzureBastionSubnet"
}

output "rgnames" {
  value = module.hub_rg.rgnames
}

output "hub_law_id" {
  value = module.hub_law.law_id
}