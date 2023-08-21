locals {
  diag_object = {
    "${var.naming_convention_info.name}" = {
      resource_id = [azurerm_kubernetes_cluster.aks_obj.id]
      log         = var.diag_object.log
      metric      = var.diag_object.metric
    }
  }
}

module "diagnostics" {
  source = "git::https://github.com/BrettOJ/tf-az-module-diagnostics-settings?ref=main"
  log_analytics_workspace_id = var.diag_object.log_analytics_workspace_id
  diag_object                = local.diag_object
  naming_convention_info     = var.naming_convention_info
  resource_type              = "aksdiag"
  tags                       = var.tags
}