# Troubleshooting Guide

## 1. Pod is in CrashLoopBackOff. What do you check?
- Check logs: `kubectl logs <pod-name> --previous` (previous crash এর logs দেখতে)
- Check `kubectl describe pod <pod-name>` for events (OOMKilled, image pull error, etc.)
- Verify the container's start command/entrypoint is correct
- Check if a readiness/liveness probe is failing and causing restarts
- Check resource limits — app may be getting OOMKilled (out of memory)

## 2. Deployment is successful, but app is not reachable. What do you check?
- Check if Pods are actually "Running" and "Ready": `kubectl get pods`
- Check the Service's selector matches the Pod's labels correctly
- Check the Service has the correct targetPort matching the container's port
- Check Ingress rules and Ingress Controller logs
- Test directly with `kubectl port-forward` to isolate if it's a Service/Ingress issue

## 3. Difference between readiness and liveness probe?
- **Readiness probe**: Checks if the Pod is ready to receive traffic. If it fails, 
  the Pod is removed from the Service's load balancing pool, but NOT restarted.
- **Liveness probe**: Checks if the Pod is still alive/healthy. If it fails 
  repeatedly, Kubernetes restarts the container.

## 4. Docker build works locally but fails in pipeline. Why?
- Different base image cache state (pipeline uses a clean environment, no local cache)
- Missing environment variables or secrets not available in CI
- File path case-sensitivity differences (Linux CI vs local OS)
- Docker version mismatch between local and CI runner
- `.dockerignore` excluding a file locally present but needed

## 5. Pipeline fails during Docker build. What do you check?
- Read the exact error message/line number in build logs
- Check if `Dockerfile` path is correct relative to build context
- Check if all files referenced by `COPY`/`ADD` actually exist in the repo
- Check network/registry access issues (base image pull failures)
- Check disk space on the CI runner

## 6. Certificate renewal failed. What do you check?
- Check cert-manager logs: `kubectl logs -n cert-manager <cert-manager-pod>`
- Verify DNS records still point to the correct Ingress/LoadBalancer IP
- Check ACME challenge (HTTP-01/DNS-01) completed successfully
- Check rate limits (Let's Encrypt has renewal rate limits)
- Verify the Certificate resource status: `kubectl describe certificate <name>`

## 7. Ingress returns 502 or 504. What do you check?
- **502 (Bad Gateway)**: Backend Pod is crashing or not responding correctly — 
  check backend Pod logs and health
- **504 (Gateway Timeout)**: Backend is too slow to respond — check backend 
  performance, database query times, or increase Ingress timeout settings
- Verify the Service and backend Pods are healthy: `kubectl get endpoints`
- Check Ingress Controller logs for connection errors

## 8. Vendor SFTP connection to port 22 times out. What do you check?
- Check NSG/firewall rules allow outbound traffic on port 22 to the vendor's IP
- Check if the vendor's server has whitelisted our outbound IP address
- Verify DNS resolution of the vendor's hostname
- Test connectivity from within the cluster/VM using `telnet <host> 22` or `nc -zv <host> 22`
- Check if a proxy or NAT gateway is required for outbound connections

## 9. Terraform plan wants to recreate the cluster. What do you check?
- Run `terraform plan` and read which specific attribute changed (often shown 
  as `-/+` in output)
- Common causes: changing an immutable field (e.g. cluster name, region, or 
  network configuration that can't be updated in-place)
- Check if the Terraform state is out of sync with actual cloud resources 
  (someone made manual changes in the portal)
- Compare `.tf` file changes against previous version with `git diff`

## 10. How would you upgrade AKS/EKS safely?
- Upgrade the control plane first, then node pools one at a time
- Use a blue-green node pool strategy: create a new node pool with the new 
  version, drain and cordon old nodes gradually, then delete old node pool
- Always test the upgrade in a dev/staging cluster first
- Check Kubernetes version compatibility with existing workloads and add-ons
- Take a backup/snapshot before upgrading

## 11. Frontend loads, but backend API calls fail. What do you check?
- Check browser console for CORS errors
- Verify the API URL the frontend is calling is correct (not localhost in production)
- Check backend Service and Pod health directly
- Check network policies aren't blocking frontend-to-backend traffic
- Check Ingress routing rules for the `/api` path

## 12. Backend pod is running, but database connection times out. What do you check?
- Check NSG rules allow traffic from the AKS subnet to the database subnet
- Verify the database's private endpoint is correctly configured
- Check if the database is actually running and accepting connections
- Verify connection string/credentials are correct (check Secret values)
- Check DNS resolution of the database hostname from within the Pod

## 13. Private DNS is not resolving database hostname. What do you check?
- Verify the Private DNS Zone is linked to the correct VNet
- Check the DNS Zone has the correct A record pointing to the Private Endpoint's IP
- Test resolution from within a Pod: `nslookup <db-hostname>`
- Check if the Pod's DNS policy is correctly configured (CoreDNS settings)
- Verify there's no conflicting public DNS record overriding resolution

## 14. How would you rotate database credentials safely?
- Create new credentials in the database without disabling the old ones yet
- Update the Secret (or Key Vault) with new values
- Perform a rolling restart of backend Pods so they pick up the new credentials
- Verify the application is working correctly with new credentials
- Only then revoke/delete the old credentials

## 15. Secrets were accidentally committed to GitHub. What do you do?
- Immediately rotate/revoke the exposed credentials (assume they're compromised)
- Remove the secret from Git history using `git filter-repo` or BFG Repo-Cleaner 
  (simply deleting in a new commit is NOT enough — it remains in history)
- Force-push the cleaned history and have all collaborators re-clone
- Enable GitHub secret scanning to catch this in the future
- Move the credential to a proper secret manager (Key Vault/Secrets Manager)
