# app-updates

The public update feed for NecturaLabs desktop apps. Each app has a folder with a small JSON
manifest that running copies of the app read to learn whether a newer version exists. Builds are
attached to this repository's GitHub Releases, tagged `<app>-build-<number>` (`<app>-v<version>` for releases made before builds were numbered), so the downloads are
public even when an app's source repository is private.

Apps fetch the manifest anonymously from
`https://raw.githubusercontent.com/NecturaLabs/app-updates/main/<app>/latest.json`. The request
carries only a `User-Agent`; nothing about the user is sent.

## Apps

| Folder | App | Source |
|---|---|---|
| [`canopy/`](canopy/) | Canopy, a Linux-first Git client | `NecturaLabs/Canopy` |

## Structure

```
<app>/
  latest.json   # newest stable build (required)
  beta.json     # newest beta build (optional; apps read it only when the user opts in)
  install.sh    # one-line installer for Linux and macOS (Canopy)
  install.ps1   # one-line installer for Windows (Canopy)
```

The installers are copied from the app's `packaging/` folder by each stable release; a beta
build never replaces them. An installer and the manifests it reads must agree on the version
format: the installers of Canopy builds read build numbers, the older ones read semantic versions,
so the first numbered release commits the new installers together with its manifest.

## Manifest format

```json
{
  "version": "412",
  "notes": "Markdown release notes",
  "pub_date": "2026-10-01T00:00:00Z",
  "release_page": "https://github.com/NecturaLabs/app-updates/releases/tag/canopy-build-412",
  "platforms": {
    "linux-x86_64": {
      "url": "https://github.com/NecturaLabs/app-updates/releases/download/canopy-build-412/canopy-build-412-x86_64-unknown-linux-gnu.tar.gz",
      "sha256": "…"
    },
    "windows-x86_64": { "url": "…", "sha256": "…" },
    "darwin-aarch64": { "url": "…", "sha256": "…" }
  }
}
```

| Field | Required | Meaning |
|---|---|---|
| `version` | yes | The build number: `git rev-list --count` of the build's commit on `main`, an integer without a leading zero (`412`). Builds are ordered by this number alone. A semantic version (`0.2.1-beta.1`), as releases made before builds were numbered carry, is accepted and is older than every build |
| `notes` | no | Markdown shown in the app's "What's new" dialog |
| `pub_date` | no | RFC 3339 release time |
| `release_page` | no | Page with the full notes and every download |
| `platforms` | no | Builds by `<os>-<arch>`: `os` is `linux`, `windows` or `darwin`; `arch` is Rust's `std::env::consts::ARCH` (`x86_64`, `aarch64`) |

A platform missing from `platforms` sends users of that platform to `release_page`.
[`schema/update-manifest.schema.json`](schema/update-manifest.schema.json) is the JSON Schema.

## Publishing

Releases are published by each app's release workflow, never by hand: it creates the
`<app>-build-<number>` release here with the builds and their `SHA256SUMS`, then commits the
updated manifest (`latest.json`, or `beta.json` for a beta build). Canopy's workflow
(`NecturaLabs/Canopy/.github/workflows/release.yml`) authenticates with the `APP_UPDATES_TOKEN`
secret, a fine-grained token with Contents: read and write on this repository only.

A channel never moves backwards: the workflow leaves a manifest that already names a higher build
alone. To withdraw a broken build, publish a newer build with the fix; apps never downgrade, so
users who already updated keep the broken build until then.
