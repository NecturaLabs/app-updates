# app-updates

Update manifests for NecturaLabs desktop apps. Artifacts are uploaded manually.

## Structure

```
discord-desktop/
  latest.json        # Tauri updater manifest
  <version>/
    discord-clone-desktop_<version>_x64-setup.nsis.zip
    discord-clone-desktop_<version>_x64-setup.nsis.zip.sig
    discord-clone-desktop_<version>_x64_en-US.msi.zip
    discord-clone-desktop_<version>_x64_en-US.msi.zip.sig
```

## latest.json format

```json
{
  "version": "0.1.0",
  "notes": "Release notes",
  "pub_date": "2026-02-28T00:00:00Z",
  "platforms": {
    "windows-x86_64": {
      "url": "https://raw.githubusercontent.com/NecturaLabs/app-updates/main/discord-desktop/0.1.0/discord-clone-desktop_0.1.0_x64-setup.nsis.zip",
      "signature": "<contents of .sig file>"
    }
  }
}
```
