# Immich Public Proxy

A lightweight proxy that sits in front of Immich and serves **only** Immich's public share links to the internet. The main Immich instance stays tailnet-private and is never exposed publicly.

## Access

| Path | URL |
|---|---|
| Public URL (Tailscale Funnel) | https://seeni-photos.stoat-perch.ts.net |
| In-cluster URL | http://immich-public-proxy.homelab.svc.cluster.local:3000 |
| Healthcheck endpoint | http://immich-public-proxy.homelab.svc.cluster.local:3000/share/healthcheck |

**No login required** — this proxy serves only Immich public share links. There is no admin UI.

### Port-forward (debug from Mac)

```bash
kubectl -n homelab port-forward svc/immich-public-proxy 3000:3000
# then open: http://localhost:3000/share/healthcheck
```

### Database

None — immich-public-proxy is fully stateless. It does not store any data.

## Umami analytics

The `seeni-photos.stoat-perch.ts.net` Funnel path now goes through
`public-inject-proxy` (nginx), which injects an Umami tracking script into
HTML responses. Binary/media/video responses pass through untouched; 206
Partial Content video streaming is preserved.

- Website ID: `72cd9142-19dc-4814-bcb7-e72fc19d0c29`
- Umami dashboard (tailnet-private): `https://umami.stoat-perch.ts.net`
- Proxy source: `/Users/nila/Developer/apps/public-inject-proxy/`

The Umami dashboard is NOT exposed via Funnel. Only `/_umami/script.js` and
`/_umami/api/send` are proxied under the seeni-photos domain — sufficient for
collection, insufficient to reach the admin UI.

Private tailnet access (`immich.stoat-perch.ts.net`) bypasses nginx and serves
unmodified HTML with no tracking script.

## Tailscale Funnel note

Public serving via `https://seeni-photos.stoat-perch.ts.net` requires a `nodeAttrs` funnel grant in the [Tailscale admin console](https://login.tailscale.com/admin/acls). This is a one-time manual step outside this repo. Check status:

```bash
kubectl -n tailscale logs -l app=ts-seeni-photos | tail -20
```
