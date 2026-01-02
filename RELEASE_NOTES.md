# PSHVTools v1.0.3

Release date: 2026-01-02

> This is the release notes for the tagged release `v1.0.3`.
> For ongoing development toward the next release (e.g. v1.0.4), see `CHANGELOG.md` under **[Unreleased]**.

## Highlights

- Restore: added `-DestinationRoot` support to `Restore-VMBackup` / `hvrestore` for simpler "where should it go" restores.
- Restore: `-DestinationRoot` defaults to **in-place registration** when `-ImportMode` is not specified.
- Docs: updated restore documentation and added a `samples/` folder with usage examples.

## Changes

### Added
- `Restore-VMBackup` / `hvrestore`: `-DestinationRoot` parameter.
- `samples/` folder with examples for `hvbak`, `hvrestore`, `fix-vhd-acl`, `hvrecover`.

### Changed
- Restore: corrected staging/extraction path handling when using `-DestinationRoot`.

## Installer / packaging

- GUI installer (Inno Setup): `dist\PSHVTools-Setup-1.0.3.exe`

## Checksums

- `dist\PSHVTools-Setup-1.0.3.exe` (SHA256):
  `1B1382C9E717D6E5C6C5FFC796C3D0EAB09C5D0A722EBCBE6A5F3FD68BADAE66`
