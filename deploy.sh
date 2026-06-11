#!/usr/bin/env bash
# deploy.sh — idempotent deploy for immich-public-proxy
# Usage: ./deploy.sh
# Safe to re-run; existing resources are patched, not replaced.
# This script does NOT modify the main Immich Deployment, Service, or Ingress.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 1. Load .env ─────────────────────────────────────────────────────────────
ENV_FILE="$SCRIPT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found."
  echo "       Copy .env.example to .env and fill in real values, then re-run."
  echo "         cp .env.example .env && \$EDITOR .env"
  exit 1
fi
# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

# ── 2. Prereq checks ─────────────────────────────────────────────────────────
if ! command -v kubectl &>/dev/null; then
  echo "ERROR: kubectl not found in PATH."
  exit 1
fi
if ! command -v envsubst &>/dev/null; then
  echo "ERROR: envsubst not found. Install via: brew install gettext"
  exit 1
fi
if ! kubectl cluster-info &>/dev/null; then
  echo "ERROR: Cannot reach the Kubernetes cluster. Is OrbStack running?"
  exit 1
fi

# ── 3. Ensure namespace exists ───────────────────────────────────────────────
NAMESPACE="${NAMESPACE:-homelab}"
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
  echo "Namespace '$NAMESPACE' not found — creating it."
  kubectl create namespace "$NAMESPACE"
else
  echo "Namespace '$NAMESPACE' already exists."
fi

# ── 4. Apply manifests via envsubst ──────────────────────────────────────────
# envsubst allow-list: only substitute NAMESPACE.
# This prevents envsubst from blanking any ${VAR} placeholders used by
# inline scripts or other manifests (e.g. CronJob env vars).
K8S_DIR="$SCRIPT_DIR/k8s"
ENVSUBST_VARS='${NAMESPACE}'

echo "Applying k8s manifests (envsubst → kubectl apply)..."
for f in \
  "$K8S_DIR/10-deployment.yaml" \
  "$K8S_DIR/20-service.yaml" \
  "$K8S_DIR/30-ingress.yaml"; do
  echo "  → $f"
  envsubst "$ENVSUBST_VARS" < "$f" | kubectl apply -f -
done

# ── 5. Wait for rollout ───────────────────────────────────────────────────────
echo "Waiting for immich-public-proxy rollout..."
kubectl -n "$NAMESPACE" rollout status deployment/immich-public-proxy --timeout=5m

# ── 6. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "✓ immich-public-proxy deployed successfully."
echo ""
echo "  Public URL (Funnel):    https://seeni-photos.stoat-perch.ts.net"
echo "  In-cluster URL:         http://immich-public-proxy.homelab.svc.cluster.local:3000"
echo "  Healthcheck:            http://immich-public-proxy.homelab.svc.cluster.local:3000/share/healthcheck"
echo ""
echo "  NOTE: Tailscale Funnel requires a nodeAttrs grant in the admin console."
echo "  If the public URL is not yet reachable, check:"
echo "    kubectl -n tailscale logs -l app=ts-seeni-photos | tail -20"
echo ""
