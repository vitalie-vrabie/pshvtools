# PSHVTools v1.0.9 Release - FINAL STATUS

## ? **Release Complete and Verified**

**Status:** ?? **LIVE & AVAILABLE FOR DOWNLOAD**

### Release Information

- **Version:** 1.0.9
- **Release Date:** 2026-01-17
- **Release URL:** https://github.com/vitalie-vrabie/pshvtools/releases/tag/v1.0.9
- **Git Tag:** `v1.0.9`
- **Latest Commit:** `22c4a9d` (fix: restore valid pshvtools.psd1 manifest file)

---

## ?? Available Downloads

### Installer (2.04 MB)
- **File:** `PSHVTools-Setup.exe`
- **SHA256:** `08b5aa9c3524d49c8a1681c9185314028cfaa3a5aa007cef765d148fb5082dd9`
- **Status:** ? Ready for installation

### Checksum File
- **File:** `PSHVTools-Setup.exe.sha256`
- **Status:** ? Available for verification

---

## ?? Release Highlights

### Major Features in v1.0.9

? **CI/CD Automation**
- GitHub Actions workflows for automated builds
- Automated test result publishing
- Release workflow with artifact generation

? **Testing Framework**
- Pester test suite with module validation
- Version consistency validation
- Module manifest verification

? **New Tools & Features**
- Configuration management: `Set-PSHVToolsConfig`, `Get-PSHVToolsConfig`, `Reset-PSHVToolsConfig`, `Show-PSHVToolsConfig`
- Health check command: `hvhealth` / `Test-PSHVToolsEnvironment`
- Enhanced build script with checksums and validation

? **Improved Build System**
- Version validation
- SHA256 checksum generation
- `-WhatIf`, `-Clean`, `-SkipVersionCheck` support
- Better error messages with actionable tips

? **Comprehensive Documentation**
- `CONTRIBUTING.md` - Developer guidelines
- `TROUBLESHOOTING.md` - Solutions for common issues
- Updated README with new commands
- PowerShell Gallery publish script

---

## ?? Installation Instructions

### Quick Install (GUI Installer)
```cmd
PSHVTools-Setup.exe
```

### Silent Install
```cmd
PSHVTools-Setup.exe /VERYSILENT /NORESTART
```

### PowerShell Install
```powershell
powershell -ExecutionPolicy Bypass -File Install.ps1
```

---

## ?? Quick Start After Installation

```powershell
# Import the module
Import-Module pshvtools

# Check environment health
hvhealth

# Configure defaults
Set-PSHVToolsConfig -DefaultBackupPath "D:\Backups" -DefaultKeepCount 5

# Backup VMs
hvbak -NamePattern "*"

# View configuration
Show-PSHVToolsConfig
```

---

## ?? CI/CD Status

### Latest Build
- **Commit:** `22c4a9d`
- **Status:** ? **PASSED**
- **Duration:** 2m 1s
- **Workflow:** Build and Test

### Build Pipeline
? Version consistency validation  
? Module manifest validation  
? Pester tests  
? Build verification  
? Artifact generation  

---

## ?? Important Links

- **Release Page:** https://github.com/vitalie-vrabie/pshvtools/releases/tag/v1.0.9
- **Repository:** https://github.com/vitalie-vrabie/pshvtools
- **Issues & Support:** https://github.com/vitalie-vrabie/pshvtools/issues
- **Contributing:** https://github.com/vitalie-vrabie/pshvtools/blob/master/CONTRIBUTING.md
- **Troubleshooting:** https://github.com/vitalie-vrabie/pshvtools/blob/master/TROUBLESHOOTING.md

---

## ?? Release Notes

Full release notes are available on the GitHub release page and in `RELEASE_NOTES.md`.

### Key Improvements Over 1.0.8

- Complete CI/CD pipeline setup
- Comprehensive test framework
- Configuration management system
- Health diagnostics command
- Enhanced build system with validation
- Extensive documentation additions

---

## ? What's Next?

Development version 1.0.10 is now active:
- Current version: 1.0.10
- All infrastructure in place for future releases
- CI/CD pipeline ready for continuous delivery

---

## ? Verification

To verify the installer checksum:

```powershell
$hash = Get-FileHash PSHVTools-Setup.exe -Algorithm SHA256
$hash.Hash
# Should output: 08b5aa9c3524d49c8a1681c9185314028cfaa3a5aa007cef765d148fb5082dd9
```

---

**? v1.0.9 Release is COMPLETE and LIVE!** ??

Users can now download and install PSHVTools 1.0.9 with all the new CI/CD, testing, and configuration management features.
