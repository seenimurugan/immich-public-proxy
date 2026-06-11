# Usage — sharing photos via Immich Public Proxy

## Prerequisites

- immich-public-proxy is deployed and the pod is Running.
- The **External domain** in Immich Server Settings is set to `https://seeni-photos.stoat-perch.ts.net`.

## One-time Immich configuration

1. Open Immich at your tailnet URL (e.g. `https://immich.stoat-perch.ts.net`).
2. Go to **Administration → Server Settings → General**.
3. Set **External domain** to `https://seeni-photos.stoat-perch.ts.net`.
4. Save.

This tells Immich to generate share links pointing at the proxy, not at itself.

## Creating a shared album

1. In Immich, open an album or select photos.
2. Click **Share** → **Create link**.
3. Configure expiry and password if desired.
4. Copy the share link — it will look like:

   ```
   https://seeni-photos.stoat-perch.ts.net/share/<key>
   ```

5. Send that URL to anyone. They access only those photos, via the proxy. Immich itself remains unreachable from the internet.

## What visitors see

Visitors get a gallery styled to match Immich's native look. They can:
- Browse photos and videos.
- Download individual files.
- Use multi-select to download a zip (if enabled in proxy config).

They cannot see any other albums, your library, or any admin functionality.

## Revoking a share

Delete the share link inside Immich. The proxy will immediately return 404 for that key.
