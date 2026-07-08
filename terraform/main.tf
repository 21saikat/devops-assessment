module "network" {
  source = "./modules/network"

  cluster_name       = var.cluster_name
  location           = var.location
  vnet_address_space = var.vnet_address_space
  aks_subnet_prefix  = var.aks_subnet_prefix
  db_subnet_prefix   = var.db_subnet_prefix
}

module "aks" {
  source = "./modules/aks"

  cluster_name        = var.cluster_name
  location            = module.network.location
  resource_group_name = module.network.resource_group_name
  kubernetes_version  = var.kubernetes_version
  node_size           = var.node_size
  node_count          = var.node_count
  aks_subnet_id       = module.network.aks_subnet_id
  environment         = var.environment
}
