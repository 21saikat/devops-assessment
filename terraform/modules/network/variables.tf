variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_prefix" {
  type = list(string)
}

variable "db_subnet_prefix" {
  type = list(string)
}
