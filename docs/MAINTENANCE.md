# Maintenance — immich-public-proxy

## Checking pod health

```bash
kubectl -n homelab get pod -l app=immich-public-proxy
kubectl -n homelab logs -l app=immich-public-proxy --tail=50
```

## Updating the image

immich-public-proxy uses `imagePullPolicy: IfNotPresent` with the `:latest` tag (third-party GHCR image, not locally built).

To pull a newer version:

```bash
# Pull the new image on the Mac (OrbStack shares Docker daemon with k3s)
docker pull ghcr.io/alangrainger/immich-public-proxy:latest

# Force a pod replacement so k8s picks up the new layer
kubectl -n homelab rollout restart deployment/immich-public-proxy
kubectl -n homelab rollout status deployment/immich-public-proxy
```

## Checking Funnel status

```bash
# Check the Tailscale proxy pod for this ingress
kubectl -n tailscale get pods | grep seeni-photos
kubectl -n tailscale logs -l app=ts-seeni-photos --tail=30
```

If Funnel says `waiting for nodeAttrs grant`, complete the one-time step in the Tailscale admin console → ACLs → add `nodeAttrs` funnel grant for this device.

## Re-deploying

```bash
cd /Users/nila/Developer/apps/immich-public-proxy
./deploy.sh
```

deploy.sh is idempotent and safe to re-run. It does NOT touch the main Immich Deployment, Service, or Ingress.

## Scaling

The Deployment runs 1 replica (stateless, safe to scale). To add replicas:

```bash
kubectl -n homelab scale deployment/immich-public-proxy --replicas=2
```
