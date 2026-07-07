# Private Database Connectivity Design

## Overview
The backend application must connect to a database privately, without exposing 
the database to the public internet. This document explains the design using 
Azure (equivalent concepts apply to AWS RDS with VPC/Security Groups).

## 1. How AKS Connects Privately to the Database

The backend (running in AKS) connects to the database through Azure's private 
networking layer instead of a public endpoint. Both AKS and the database live 
inside the same Virtual Network (VNet), so traffic never leaves Azure's internal 
network or touches the public internet.

## 2. Private Subnet / Private Endpoint Design

- The database (Azure PostgreSQL/MySQL) is deployed with **Public Network Access 
  disabled**.
- A **Private Endpoint** is created inside a dedicated subnet (e.g. `snet-database`) 
  within the same VNet as the AKS cluster.
- The Private Endpoint gives the database a private IP address (e.g. `10.0.2.4`) 
  from within the VNet's address space, instead of a public IP.
- AKS nodes live in a separate subnet (e.g. `snet-aks`), and both subnets are 
  part of the same VNet, allowing internal routing.

## 3. Private DNS Requirement

- Without private DNS, the backend's database connection string (e.g. 
  `mydb.postgres.database.azure.com`) would resolve to a **public IP** by default.
- A **Private DNS Zone** (`privatelink.postgres.database.azure.com`) is linked 
  to the VNet. This overrides DNS resolution so the same hostname resolves to 
  the **private IP** of the Private Endpoint instead.
- This means the backend code doesn't need to change — it uses the same 
  hostname, but traffic now stays internal.

## 4. NSG / Firewall Rules

- A **Network Security Group (NSG)** is attached to the database subnet.
- Inbound rule: Allow traffic **only** from the AKS subnet's IP range (e.g. 
  `10.0.1.0/24`) on the database port (5432 for PostgreSQL / 3306 for MySQL).
- All other inbound traffic (including from the internet) is denied by default.

## 5. How Only Backend Can Access the Database

- The database's NSG only allows traffic from the AKS node subnet — not from 
  the frontend, not from the internet.
- Additionally, Kubernetes NetworkPolicies can be used inside the cluster to 
  ensure only Pods labeled `app: backend` can send traffic to the database, 
  even restricting frontend Pods within the same cluster from reaching it 
  directly.

## 6. How Database Credentials Are Stored Securely

- Credentials (username/password) are **never hardcoded** in the application 
  code or Docker image.
- In this assessment, `k8s/backend-secret-example.yaml` demonstrates the 
  structure using a Kubernetes Secret (base64-encoded, for local demo purposes).
- In a real production environment, credentials would be stored in **Azure Key 
  Vault**, and the backend Pod would access them at runtime using the **Secrets 
  Store CSI Driver**, which mounts Key Vault secrets directly into the Pod — 
  avoiding storage of plaintext credentials in Kubernetes Secrets or Git 
  entirely.

## 7. How to Confirm the Database Is Not Publicly Accessible

- In the Azure Portal, check the database resource's **Networking** tab — 
  "Public network access" should show **Disabled**.
- From a local machine (outside the VNet), attempting to connect to the 
  database hostname should **time out or fail to resolve**, confirming there 
  is no public route.
- From within an AKS Pod (backend), the same hostname should resolve to a 
  private IP (10.x.x.x range) and successfully connect — confirming private 
  connectivity works correctly.

## Summary Diagram (Conceptual)

```
[Internet] --X--> [Database]  (blocked - no public access)

[AKS Pod: backend] --> [Private Endpoint] --> [Database]
        (via VNet, private IP, NSG-restricted)

[AKS Pod: frontend] --X--> [Database]  (blocked - NSG only allows backend subnet)
```
