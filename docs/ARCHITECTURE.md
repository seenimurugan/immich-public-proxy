# Architecture — immich-public-proxy

## Data flow

```
Public Internet
      │
      │  HTTPS (Tailscale Funnel)
      ▼
┌─────────────────────────┐
│  Tailscale Funnel       │  seeni-photos.stoat-perch.ts.net
│  (ts-seeni-photos pod)  │
└────────────┬────────────┘
             │  HTTP inside cluster
             ▼
┌────────────────────────────────────────────────────────┐
│  Namespace: homelab                                    │
│                                                        │
│  ┌──────────────────────────┐                          │
│  │  immich-public-proxy     │  ClusterIP :3000         │
│  │  (Node.js / port 3000)   │                          │
│  └──────────────┬───────────┘                          │
│                 │  HTTP (API calls, asset fetch)        │
│                 ▼                                       │
│  ┌──────────────────────────┐                          │
│  │  immich-server           │  ClusterIP :2283         │
│  │  (main Immich instance)  │                          │
│  └──────────────────────────┘                          │
└────────────────────────────────────────────────────────┘
```

## Why this keeps Immich private

The main Immich `Service` (`immich-server:2283`) has **no** Tailscale Ingress and no Funnel annotation. It is only reachable from within the cluster network (ClusterIP) or from Tailnet devices that have direct pod/service access.

`immich-public-proxy` is the **only** component exposed publicly. It is stateless, requires no API key, and its code is intentionally small enough to be fully audited. All requests to Immich are read-only and validated — it can only return assets that you have explicitly shared.

## Components

| Component | Image | Port | Pull policy |
|---|---|---|---|
| immich-public-proxy | `ghcr.io/alangrainger/immich-public-proxy:latest` | 3000 | IfNotPresent |

## Kubernetes resources

| Resource | Name | Namespace |
|---|---|---|
| Deployment | immich-public-proxy | homelab |
| Service (ClusterIP) | immich-public-proxy | homelab |
| Ingress (Tailscale Funnel) | immich-public-proxy | homelab |
| Tailscale proxy pod | ts-seeni-photos-* | tailscale |
