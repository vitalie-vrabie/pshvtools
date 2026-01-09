# PSHVTools v1.0.5

Release date: 2026-01-09

## Highlights

- Backup: temp folder creation aligned to checkpoint timestamp and de-duplicated to improve export/cleanup reliability.
- Utility: added GPU partition adapter removal helper and module alias (`nogpup`).

## Changes

### Added
- Utility: `scripts/remove-gpu-partitions.ps1` to remove GPU partition adapters from VMs matched by wildcard name.
- Module: `nogpup` alias to run GPU-partition removal through `pshvtools`.

### Fixed
- Backup: avoid duplicate per-VM temp export folder creation which could interfere with cleanup.

## Usage samples

### Backup VMs (hvbak)

```powershell
# Backup all VMs
hvbak -NamePattern "*"

# Backup a subset and keep last 5 archives
hvbak -NamePattern "lab-*" -KeepCount 5
```

### Remove GPU partition adapters (nogpup)

```powershell
# Load the module
Import-Module pshvtools

# Remove GPU partition adapters from matching VMs
nogpup -NamePattern "lab-*"

# Preview actions only
nogpup -NamePattern "*" -WhatIf
```

## Installer / packaging

- GUI installer (Inno Setup): `dist\PSHVTools-Setup-1.0.5.exe`
