# PSHVTools v1.0.11 Release

**Release Date:** January 18, 2026  
**Status:** Development Build (Pre-release)  
**GitHub Tag:** [v1.0.11](https://github.com/vitalie-vrabie/pshvtools/releases/tag/v1.0.11)

## ?? What's New in v1.0.11

### ? New Features

#### 1. **VHD Compaction Command** - `hvcompact` / `hv-compact`
- **Function:** `Invoke-VHDCompact`
- **Purpose:** Compact VHDs to reclaim unused space
- **Features:**
  - Compact all VHDs matching a wildcard VM pattern
  - Full reclamation mode for maximum space recovery
  - Real-time progress reporting
  - Automatic safety checks (VM must be stopped)
  - Detailed error handling and summary

**Usage:**
```powershell
hvcompact -NamePattern "*"           # Compact all VMs
hvcompact -NamePattern "srv-*"       # Compact matching VMs
hv-compact "web-*"                   # Hyphenated alias
```

#### 2. **VHD ACL Repair Command** - `hvfixacl` / `hv-fixacl`
- **Function:** `Repair-VhdAcl` (renamed from `fix-vhd-acl`)
- **Purpose:** Fix VHD/VHDX ACL permissions after restore/copy
- **Features:**
  - Fix permissions for all attached VHDs on host
  - Process specific folders with `-VhdFolder`
  - Process VHDs from CSV list with `-VhdListCsv`
  - Automatic ownership takeover and permission grants
  - Comprehensive logging to `hvfixacl.log`

**Usage:**
```powershell
hvfixacl                            # Fix all VMs' VHDs
hvfixacl -VhdFolder "D:\Restores"   # Fix VHDs in folder
hv-fixacl -VhdListCsv "C:\list.csv" # Fix from CSV
```

### ?? Alias Standardization

Added consistent hyphenated aliases (`hv-*`) for all commands:

| Command | New Aliases |
|---------|------------|
| Backup | `hvbak`, `hv-bak` |
| VHD Repair | `hvfixacl`, `hv-fixacl` |
| Restore | `hvrestore`, `hv-restore` |
| Recovery | `hvrecover`, `hv-recover` |
| GPU Partition Removal | `hvnogpup`, `hv-nogpup` |
| Clone | `hvclone`, `hv-clone` |
| VHD Compaction | `hvcompact`, `hv-compact` |
| Health Check | `hvhealth`, `hv-health` |

### ?? Changes & Improvements

- **Renamed Commands:**
  - `fix-vhd-acl` ? `hvfixacl` (with alias `hv-fixacl`)
  - `nogpup` ? `hvnogpup` (with alias `hv-nogpup`)
  - Legacy aliases kept for backward compatibility during migration

- **Version Consistency:**
  - Updated all version references to 1.0.11
  - Updated `version.json`, `pshvtools.psd1`, and installer configuration
  - Added comprehensive changelog entry

- **Documentation Updates:**
  - Updated README.md with new commands
  - Comprehensive QUICKSTART.md sections for new features
  - Added 12 hvcompact and 9 hvfixacl usage examples
  - Updated contributing guidelines and examples

- **Installer Improvements:**
  - Dev build warning now triggers for 1.0.11 (compared to stable 1.0.9)
  - Fixed `MyAppLatestStableVersion` configuration
  - Users see acknowledgment prompt during installation

## ?? Download

**Installer:** [PSHVTools-Setup.exe (2.14 MB)](https://github.com/vitalie-vrabie/pshvtools/releases/download/v1.0.11/PSHVTools-Setup.exe)

**SHA256 Checksum:**
```
E5910BB7C0AECF509DBFE8C625B516B5083C30B4E3538E216070C00BDB13377D
```

## ?? Installation

### Using Installer (Recommended)
1. Download `PSHVTools-Setup.exe`
2. Run the installer
3. Follow the wizard
4. Installation complete!

### Using PowerShell
```powershell
# Extract installer contents manually or use
PSHVTools-Setup.exe /VERYSILENT /NORESTART
```

### Import Module
```powershell
Import-Module pshvtools
Get-Command -Module pshvtools
```

## ?? Quick Examples

### Backup VMs
```powershell
hvbak -NamePattern "*"                    # Backup all VMs
hv-bak -NamePattern "srv-*"               # Backup matching VMs
```

### Compact VHDs
```powershell
hvcompact -NamePattern "*"                # Compact all VMs' VHDs
hv-compact -NamePattern "web-*"           # Compact specific VMs
```

### Fix VHD Permissions
```powershell
hvfixacl                                  # Fix all attached VHDs
hv-fixacl -VhdFolder "D:\Restores"        # Fix folder contents
```

### Restore from Backup
```powershell
hvrestore -VmName "MyVM" -Latest          # Restore latest backup
hv-restore -BackupPath "path\file.7z"     # Restore specific backup
```

## ?? System Requirements

- **OS:** Windows Server 2008 R2 or later
- **PowerShell:** 5.1 or later
- **Hyper-V:** Windows Server with Hyper-V role
- **7-Zip:** Required for backup/restore (7z.exe)

## ?? Development Build Notice

**v1.0.11 is a development build** compared to stable release v1.0.9.

When installing, you'll see:
```
This installer appears to be a development build.
Installer version: 1.0.11
Latest stable release: 1.0.9

This build may be unstable. You must acknowledge before continuing.
```

This is **normal and expected** for pre-release versions. The features are tested and ready for use!

## ?? Breaking Changes

- **Removed:** Legacy alias `fix-vhd-acl` (use `hvfixacl` or `hv-fixacl`)
- **Removed:** Legacy alias `nogpup` (use `hvnogpup` or `hv-nogpup`)

Scripts using old aliases should be updated to use new names.

## ?? Documentation

- **[README.md](https://github.com/vitalie-vrabie/pshvtools#readme)** - Full documentation
- **[QUICKSTART.md](https://github.com/vitalie-vrabie/pshvtools/blob/master/QUICKSTART.md)** - Getting started guide
- **[CHANGELOG.md](https://github.com/vitalie-vrabie/pshvtools/blob/master/CHANGELOG.md)** - Complete version history
- **[BUILD_GUIDE.md](https://github.com/vitalie-vrabie/pshvtools/blob/master/BUILD_GUIDE.md)** - Developer guide

## ?? Bug Reports & Features

Found a bug or have a feature request? [Open an issue on GitHub](https://github.com/vitalie-vrabie/pshvtools/issues)

## ?? License

MIT License - See [LICENSE.txt](https://github.com/vitalie-vrabie/pshvtools/blob/master/LICENSE.txt)

---

**Thank you for using PSHVTools!** ??
