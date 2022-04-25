module "kv_vmsecrets" {
  source        = "app.terraform.io/roman2025/kv/azurerm"
  version = "0.0.4"
  keyvault_name = "vmsecrets"
  enviro        = var.enviro
  prjnum        = var.prjnum
  location      = var.location
  orgname       = var.orgname
  rgname        = lookup(module.hub_rg.rgnames, "Security", "fail")
  usecase       = "vmpasswords"
  disk_encryption = false
  soft_del_days   = 7
  prg_protect     = false
  sku             = "standard"
  tenantid        = data.azurerm_client_config.current.tenant_id
  clientuserid    = data.azurerm_client_config.current.object_id
}