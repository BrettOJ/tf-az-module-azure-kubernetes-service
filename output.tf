output "aks_output" {
  value = azurerm_kubernetes_cluster.aks_obj
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_obj.kube_config
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks_obj.kube_config_raw
}

output "ssh_key" {
  value     = base64encode(tls_private_key.key.private_key_pem)
  sensitive = true
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_obj.name
}
