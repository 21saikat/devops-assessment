# Terraform - AKS Infrastructure

This folder provisions a production-style Azure Kubernetes Service (AKS)
cluster using a custom, module-based Terraform structure.

## Structure

    terraform/
      provider.tf       - Azure provider + remote backend config
      variables.tf       - Root-level input variables
      main.tf            - Calls the network and aks modules
      outputs.tf         - Root-level outputs
      modules/
        network/         - VNet, subnets, NSG (custom module)
        aks/              - AKS cluster, ACR, Log Analytics (custom module)

## What Gets Created

- Resource Group
- Virtual Network with two subnets (AKS + Database)
- Network Security Group restricting database access to the AKS subnet only
- AKS Cluster with a system-assigned identity and Azure CNI networking
- Azure Container Registry (ACR), with AKS granted pull access via role assignment
- Log Analytics Workspace for cluster monitoring

## How to Use

    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan

## Upgrading AKS Safely

1. Check available upgrade versions: az aks get-upgrades
2. Update kubernetes_version in variables.tf
3. Run terraform plan to review the change before applying
4. Apply during a low-traffic window; AKS upgrades nodes one at a time using
   the max_surge setting to avoid downtime

## Adding or Resizing Node Pools

- To resize: update node_count or node_size in variables.tf and run terraform apply
- To add a new node pool for a different workload, define a new
  azurerm_kubernetes_cluster_node_pool resource in the aks module

## Maintaining Terraform State

- State is stored remotely in an Azure Storage Account (see backend "azurerm"
  in provider.tf), not locally, so it survives VM loss and supports team collaboration
- Azure Storage's native blob leasing provides state locking, preventing
  concurrent apply operations from corrupting state

## Avoiding Downtime During Cluster Changes

- upgrade_settings with max_surge ensures new nodes are created before old
  ones are removed during upgrades
- Readiness probes defined in k8s/ ensure traffic only reaches healthy Pods
  during any node replacement

## Separating Dev, Staging, and Production

- Use separate .tfvars files per environment (dev.tfvars, prod.tfvars) with
  different cluster_name, node_count, and node_size
- Use separate remote state files/keys per environment to keep state fully
  isolated: terraform apply -var-file=dev.tfvars

## Handling Secrets Outside Terraform Code

- No credentials are hardcoded in any .tf file
- Database credentials are managed separately via Azure Key Vault (see
  docs/database-connectivity.md), not through Terraform variables in plain text

## What to Check if Terraform Wants to Recreate the Cluster

- Run terraform plan and check which specific field is marked as forcing replacement
- Common causes: changing an immutable field like the cluster name or region
- Check if someone made a manual change directly in the Azure Portal, causing
  state drift; reconcile with terraform refresh before applying
