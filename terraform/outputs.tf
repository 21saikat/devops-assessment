output "cluster_name" {
  value = module.aks.cluster_name
}

output "cluster_endpoint" {
  value = module.aks.cluster_endpoint
}

output "acr_login_server" {
  value = module.aks.acr_login_server
}

output "resource_group_name" {
  value = module.network.resource_group_name
}

output "vnet_id" {
  value = module.network.vnet_id
}
