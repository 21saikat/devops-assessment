output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.main.fqdn
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}
