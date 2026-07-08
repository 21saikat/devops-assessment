variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "node_size" {
  type = string
}

variable "node_count" {
  type = number
}

variable "aks_subnet_id" {
  type = string
}

variable "environment" {
  type = string
}
