variable "environment" {
  description = "Deployment environment (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "devops-assessment-aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.28"
}

variable "node_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "Address prefix for the AKS node subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "db_subnet_prefix" {
  description = "Address prefix for the database subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
