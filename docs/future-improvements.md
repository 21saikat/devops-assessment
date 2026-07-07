# Future Improvement Proposals

## 1. Secret Management with Azure Key Vault

**What:** Replace Kubernetes Secrets (base64-encoded) with Azure Key Vault, 
accessed via the Secrets Store CSI Driver.

**Why it's needed:** Base64 encoding is not encryption — anyone with cluster 
access can trivially decode secrets. Key Vault provides real encryption at 
rest, access auditing, and centralized rotation.

**How it helps the team/business:** Reduces the risk of credential leaks and 
gives a single, auditable place to manage all secrets across environments.

**How it would be implemented:** Install the Secrets Store CSI Driver + Azure 
Key Vault provider, create a `SecretProviderClass` resource, and mount secrets 
directly into Pods instead of using native Kubernetes Secrets.

**Risk reduced:** Credential exposure through Git history, cluster access, or 
etcd snapshots.

---

## 2. Image Vulnerability Scanning

**What:** Add automated container image scanning (e.g. Trivy or Azure Defender 
for Containers) into the CI/CD pipeline.

**Why it's needed:** Base images and dependencies can contain known CVEs 
(vulnerabilities) that go unnoticed without automated scanning.

**How it helps the team/business:** Catches security issues before deployment, 
reducing the chance of shipping vulnerable code to production.

**How it would be implemented:** Add a scanning step in GitHub Actions after 
the Docker build step; fail the pipeline if critical/high vulnerabilities are 
found.

**Risk reduced:** Running containers with known, exploitable vulnerabilities 
in production.

---

## 3. Production-Grade WSGI Server

**What:** Replace Flask's built-in development server with Gunicorn.

**Why it's needed:** Flask's dev server explicitly warns it's not meant for 
production — it's single-threaded and not designed for concurrent load.

**How it helps the team/business:** Improves performance, stability, and 
ability to handle concurrent requests under real traffic.

**How it would be implemented:** Add `gunicorn` to `requirements.txt`, update 
the Dockerfile `CMD` to `gunicorn --bind 0.0.0.0:8080 app:app`.

**Risk reduced:** Application instability or crashes under production load.

---

## 4. GitOps with Argo CD

**What:** Introduce Argo CD to manage Kubernetes deployments declaratively 
from Git, instead of `kubectl apply` in the pipeline.

**Why it's needed:** Manual/pipeline-triggered deploys don't provide drift 
detection or easy rollback visibility.

**How it helps the team/business:** Git becomes the single source of truth; 
any manual cluster changes are detected and can be auto-corrected. Rollbacks 
become a simple `git revert`.

**How it would be implemented:** Install Argo CD in the cluster, point it at 
the `k8s/` folder in this repo, and let it continuously sync cluster state 
with Git.

**Risk reduced:** Configuration drift between what's in Git and what's 
actually running.

---

## 5. Blue/Green or Canary Deployments

**What:** Introduce progressive delivery instead of directly replacing all 
Pods at once during deployment.

**Why it's needed:** A bad deployment currently affects 100% of traffic 
immediately.

**How it helps the team/business:** Reduces the blast radius of bad releases 
— issues are caught with a small percentage of traffic before full rollout.

**How it would be implemented:** Use Argo Rollouts or native Kubernetes 
strategies to gradually shift traffic from the old version to the new version, 
monitoring error rates at each step.

**Risk reduced:** Full-scale outages from bad deployments.

---

## 6. Cost Optimization with Cluster Autoscaler + Spot Nodes

**What:** Enable AKS Cluster Autoscaler and use Spot node pools for 
non-critical workloads.

**Why it's needed:** Fixed node pools waste money during low-traffic periods 
and may under-provision during spikes.

**How it helps the team/business:** Reduces cloud spend significantly while 
maintaining the ability to scale up during real demand.

**How it would be implemented:** Enable autoscaling on the AKS node pool via 
Terraform (`enable_auto_scaling = true`), and create a secondary Spot node 
pool for fault-tolerant workloads.

**Risk reduced:** Over-provisioning costs and under-provisioning during 
traffic spikes.
