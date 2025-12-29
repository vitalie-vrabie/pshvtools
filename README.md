# PSVMTools - Complete Distribution Package

**Version:** 1.0.0  
**Product Name:** PSVMTools (PowerShell VM Tools)  
**Module Name:** vmbak  
**License:** MIT

---

## ?? What is PSVMTools?

PSVMTools is a professional PowerShell module for backing up Hyper-V virtual machines. It provides the `vmbak` cmdlet for automated, parallel VM backups with checkpoint support and 7-Zip compression.

### Key Features:
- ? Live VM backups using Production checkpoints
- ? Parallel processing of multiple VMs
- ? 7-Zip compression with multithreading
- ? Automatic cleanup (keeps 2 most recent backups)
- ? Progress tracking with real-time status
- ? Graceful cancellation (Ctrl+C support)
- ? Low-priority compression (Idle CPU class)

---

## ?? For End Users - Installation

### Option 1: PowerShell Installer (Easiest)
1. Download the release package
2. Right-click `PSVMTools-Setup.bat`
3. Select **"Run as Administrator"**
4. Done!

### Option 2: EXE Installer
1. Download `PSVMTools-Setup-1.0.0.exe`
2. Double-click to install
3. Follow the wizard
4. Done!

### Option 2: MSI Installer
1. Download `PSVMTools-Setup-1.0.0.msi`
2. Double-click to install
3. Follow the wizard
4. Done!

After installation:
```powershell
# Display help
vmbak

# Backup all VMs
vmbak -NamePattern "*"
```

**Full user documentation:** See [QUICKSTART.md](QUICKSTART.md)

---

## ?? For Developers - Building

### Build All Installers
```powershell
.\Build-All-Installers.ps1
```

### Build Specific Installer
```powershell
# PowerShell self-extractor only
.\Build-PSVMTools-Installer.ps1

# NSIS EXE only (requires NSIS)
makensis PSVMTools-Installer.nsi

# WiX MSI only (requires WiX Toolset)
.\Build-WixInstaller.ps1
```

**Full build documentation:** See [BUILD_GUIDE.md](BUILD_GUIDE.md)

---

## ?? Repository Structure

```
PSVMTools/
??? vmbak.ps1                          # Core backup script
??? vmbak.psm1                         # PowerShell module
??? vmbak.psd1                         # Module manifest
??? Install-vmbak.ps1                  # Manual installer
??? Uninstall-vmbak.ps1                # Manual uninstaller
?
??? Build-PSVMTools-Installer.ps1      # Builds self-extracting installer
??? Build-All-Installers.ps1           # Builds all installer types
??? PSVMTools-Installer.nsi            # NSIS installer script
?
??? README_VMBAK_MODULE.md             # Module documentation
??? QUICKSTART.md                      # Quick start guide
??? BUILD_GUIDE.md                     # Build instructions
??? PACKAGE_README.md                  # Package documentation
??? LICENSE.txt                        # MIT license
?
??? dist/                              # Build output (created by scripts)
    ??? PSVMTools-Setup.ps1           # Self-extracting installer
    ??? PSVMTools-Setup.bat           # Installer launcher
    ??? PSVMTools-Uninstall.bat       # Uninstaller
    ??? PSVMTools-Setup-1.0.0.exe     # NSIS installer (if built)
    ??? PSVMTools-1.0.0-Complete.zip  # Complete package
```

---

## ?? Distribution Options

### For GitHub Releases

Create three distribution options:

1. **PSVMTools-1.0.0-Complete.zip**
   - Complete package with all methods
   - Best for users who want choices

2. **PSVMTools-1.0.0-PowerShell.zip**
   - PowerShell installer only
   - Lightweight, no dependencies

3. **PSVMTools-Setup-1.0.0.exe**
   - Traditional Windows installer
   - Best for enterprise/IT departments

3. **PSVMTools-Setup-1.0.0.msi**
   - Windows Installer (MSI) package
   - Best for enterprise/IT departments

### For Enterprise IT Departments

**Recommended:** NSIS EXE Installer
**Recommended:** MSI Installer
- Professional installer experience
- Industry-standard Windows Installer
- Add/Remove Programs integration
- Silent install support: `/S`
- Silent install: `msiexec /i PSVMTools-Setup-1.0.0.msi /quiet`
- Group Policy deployment ready

### For Quick Sharing

**Recommended:** PowerShell Installer
- Just 3 files (Setup.bat, Setup.ps1, Uninstall.bat)
- No external dependencies
- Works everywhere

---

## ?? Quick Reference

### Build Commands
```powershell
# Build everything
.\Build-All-Installers.ps1

# Clean build
.\Build-All-Installers.ps1 -CleanFirst

# Skip NSIS (faster)
.\Build-All-Installers.ps1 -SkipNSIS
```

### Installation Commands
```powershell
# PowerShell installer
.\PSVMTools-Setup.bat

# NSIS installer
.\PSVMTools-Setup-1.0.0.exe

# MSI installer
msiexec /i PSVMTools-Setup-1.0.0.msi

# Silent PowerShell install
powershell.exe -ExecutionPolicy Bypass -File "PSVMTools-Setup.ps1" -Action Install -Scope System

# Silent NSIS install
PSVMTools-Setup-1.0.0.exe /S

# Silent MSI install
msiexec /i PSVMTools-Setup-1.0.0.msi /quiet /norestart
```

### Usage Commands
```powershell
# Display help
vmbak

# Backup all VMs
vmbak -NamePattern "*"

# Backup specific VMs
vmbak -NamePattern "srv-*"

# Custom destination
vmbak -NamePattern "*" -Destination "D:\backups"

# Detailed help
Get-Help vmbak -Full
```

---

## ?? Documentation Index

| Document | Description | Target Audience |
|----------|-------------|-----------------|
| [README_VMBAK_MODULE.md](README_VMBAK_MODULE.md) | Module features and usage | End Users |
| [QUICKSTART.md](QUICKSTART.md) | Quick start guide | End Users |
| [BUILD_GUIDE.md](BUILD_GUIDE.md) | Building installers | Developers |
| [PACKAGE_README.md](PACKAGE_README.md) | Package overview | Distributors |
| [LICENSE.txt](LICENSE.txt) | MIT license | Everyone |

---

## ?? System Requirements

### Minimum Requirements
- Windows Server 2016 or Windows 10 (with Hyper-V)
- PowerShell 5.1 or later
- Hyper-V PowerShell module
- 7-Zip installed (7z.exe in PATH)
- Administrator privileges

### Recommended
- Windows Server 2019 or later
- PowerShell 7+
- Fast storage for temp folder
- Sufficient disk space for backups

---

## ?? Support

- **GitHub Issues:** https://github.com/vitalie-vrabie/scripts/issues
- **GitHub Repository:** https://github.com/vitalie-vrabie/scripts
- **Documentation:** See docs folder after installation

---

## ?? License

MIT License - See [LICENSE.txt](LICENSE.txt) for full details

Copyright (c) 2025 Vitalie Vrabie

---

## ?? Getting Started

### For End Users
1. Download the installer (any type)
2. Run as Administrator
3. Type `vmbak` to see help
4. Start backing up VMs!

### For Developers
1. Clone the repository
2. Run `.\Build-All-Installers.ps1`
3. Find built installers in `dist/` folder
4. Test and distribute!

---

## ?? Version History

### Version 1.0.0 (2025)
- Initial release
- Core backup functionality
- Multiple installer types
- Complete documentation
- PowerShell module integration

---

## ?? Highlights

- **Zero Configuration:** Works out of the box
- **Professional:** Enterprise-ready features
- **Flexible:** Multiple installation methods
- **Well Documented:** Comprehensive guides
- **Open Source:** MIT licensed

---

**Thank you for using PSVMTools!** ??

For questions, issues, or contributions, visit:  
https://github.com/vitalie-vrabie/scripts
