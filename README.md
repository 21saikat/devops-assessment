# DevOps Engineer Assessment — LogicMatrix

A production-style platform demonstrating Docker, CI/CD, Kubernetes, Terraform, 
and cloud security practices, built for the DevOps Engineer assessment.

## Project Structure

- `frontend/` — Static HTML frontend (Nginx), calls the backend API
- `backend/` — Flask API with health checks, logging, and CORS support
- `docker-compose.yml` — Runs both services locally
- `.github/workflows/` — CI/CD pipeline (GitHub Actions)
- `k8s/` — Kubernetes manifests (Deployments, Services, Ingress, ConfigMap, Secret)
- `terraform/` — Module-based Infrastructure as Code for AKS
- `docs/` — Database connectivity design, troubleshooting guide, future improvements

## Quick Start (Local)

```bash
docker compose up -d --build
curl http://localhost:8080/health
curl http://localhost:3000
```

## Tech Stack

Docker, Docker Compose, GitHub Actions, Kubernetes (AKS), Terraform, 
Azure (VNet, NSG, Log Analytics, ACR), Flask, Nginx

## Documentation

- [Database Connectivity Design](docs/database-connectivity.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Future Improvements](docs/future-improvements.md)
- [Terraform README](terraform/README.md)

## Author

Abu Jor Al Gefari (Saikat) — Azure & AWS Cloud | DevOps & MLOps Engineer  
AZ-104 · AZ-305 Certified
