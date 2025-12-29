# PSVMTools - PowerShell VM Backup Tools
## Installation Package

Version 1.0.0

### Overview

PSVMTools is a comprehensive PowerShell module for backing up Hyper-V virtual machines using checkpoints and 7-Zip compression. This package contains everything needed to install and use the `vmbak` cmdlet.

---

## Package Contents

This installer package includes:

- **vmbak.ps1** - Main backup script
- **vmbak.psm1** - PowerShell module
- **vmbak.psd1** - Module manifest
- **Documentation** - Quick start guide and comprehensive documentation
- **Installer/Uninstaller** - Automated installation tools

---

## Installation Methods

### Method 1: PowerShell Self-Extracting Installer (Recommended)

The PowerShell-based installer embeds all files and requires no external dependencies.

**Steps:**
1. Right-click `PSVMTools-Setup.bat`
2. Select **"Run as Administrator"**
3. Follow the on-screen prompts

**Alternative (PowerShell):**
```powershell
# Run as Administrator
.\PSVMTools-Setup.ps1 -Action Install -Scope System
```

**Features:**
- ? No external dependencies
- ? Self-contained single-file installer
- ? Automatic module registration
- ? Built-in uninstaller
- ? Works on any Windows system with PowerShell 5.1+

---

### Method 2: MSI Installer (Windows Installer)

If you prefer a traditional Windows installer, use the WiX-built MSI package.

**Prerequisites:**
- Download and install WiX Toolset from https://wixtoolset.org/releases/
- Or install via Chocolatey: `choco install wixtoolset`

**To Build the MSI Installer:**
```powershell
# 1. Install WiX Toolset from https://wixtoolset.org/releases/
# 2. Run the build script:
.\Build-WixInstaller.ps1
# OR use the master build script:
.\Build-All-Installers.ps1
```

**To Install:**
1. Double-click `PSVMTools-Setup-1.0.0.msi`
2. Follow the installation wizard
3. Module will be automatically registered

**Features:**
- ? Industry-standard Windows Installer (MSI)
- ? Transactional installation with rollback
- ? Start Menu shortcuts
- ? Add/Remove Programs integration
- ? Group Policy deployment support
- ? Silent install support

---

### Method 3: Manual Installation

For advanced users or automated deployments.

```powershell
# Run as Administrator
.\Install-vmbak.ps1 -Scope System
```

---

## Quick Start

After installation, the `vmbak` cmdlet is available system-wide:

### Display Help
```powershell
vmbak
```

### Basic Usage
```powershell
# Backup all VMs
vmbak -NamePattern "*"

# Backup specific VMs
vmbak -NamePattern "srv-*"

# Custom destination
vmbak -NamePattern "*" -Destination "D:\backups"

# Get detailed help
Get-Help vmbak -Full
```

---

## System Requirements

### Minimum Requirements:
- Windows Server 2016 or Windows 10 (with Hyper-V)
- PowerShell 5.1 or later
- Hyper-V PowerShell module
- 7-Zip installed (7z.exe in PATH)
- Administrator privileges

### Recommended:
- Windows Server 2019 or later
- PowerShell 7+
- Sufficient disk space for backups
- Fast storage for temp folder (E:\vmbkp.tmp)

---

## Uninstallation

### Using Batch File:
1. Right-click `PSVMTools-Uninstall.bat`
2. Select **"Run as Administrator"**

### Using PowerShell:
```powershell
# Run as Administrator
.\PSVMTools-Setup.ps1 -Action Uninstall
```

### Using Add/Remove Programs:
1. Open Settings ? Apps
2. Find "PSVMTools"
3. Click Uninstall

### Manual Uninstallation:
```powershell
# Run as Administrator
.\Uninstall-vmbak.ps1 -Scope System
```

---

## Package Structure

```
PSVMTools/
??? Build-PSVMTools-Installer.ps1    # Builds the self-extracting installer
??? Build-WixInstaller.ps1           # Builds the MSI installer
??? PSVMTools-Installer.wxs          # WiX installer definition
??? dist/                            # Output folder for built installers
?   ??? PSVMTools-Setup.ps1         # Self-extracting installer
?   ??? PSVMTools-Setup.bat         # Batch wrapper (run as admin)
?   ??? PSVMTools-Uninstall.bat     # Uninstaller batch file
?   ??? PSVMTools-Setup-1.0.0.msi   # MSI installer
??? vmbak.ps1                        # Main backup script
??? vmbak.psm1                       # PowerShell module
??? vmbak.psd1                       # Module manifest
??? Install-vmbak.ps1                # Manual installer
??? Uninstall-vmbak.ps1              # Manual uninstaller
??? README_VMBAK_MODULE.md           # Module documentation
??? QUICKSTART.md                    # Quick start guide
??? LICENSE.txt                      # License information
??? PACKAGE_README.md                # This file
```

---

## Building the Installers

### Build Self-Extracting PowerShell Installer:
```powershell
# Run from the repository root
.\Build-PSVMTools-Installer.ps1

# Output will be in ./dist folder
# Files created:
#   - PSVMTools-Setup.ps1 (self-extracting installer)
#   - PSVMTools-Setup.bat (batch wrapper)
#   - PSVMTools-Uninstall.bat (uninstaller)
```

### Build MSI EXE Installer:
```bash
# After installing WiX Toolset:
.\Build-WixInstaller.ps1

# Or use the master build script:
.\Build-All-Installers.ps1

# Output: dist/PSVMTools-Setup-1.0.0.msi
```

---

## Distribution

### For Self-Extracting Installer:
Distribute the `dist` folder containing:
- PSVMTools-Setup.bat
- PSVMTools-Setup.ps1
- PSVMTools-Uninstall.bat

### For MSI Installer:
Distribute the single file:
- PSVMTools-Setup-1.0.0.msi

---

## Troubleshooting

### "Execution policy" errors:
```powershell
# Set execution policy (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Module not found after installation:
```powershell
# Check installation
Get-Module vmbak -ListAvailable

# Manually import if needed
Import-Module vmbak -Force
```

### "Access denied" errors:
- Ensure you're running as Administrator
- Check antivirus hasn't blocked the installer
- Verify you have write access to Program Files

### 7-Zip not found:
```powershell
# Install 7-Zip from https://www.7-zip.org/
# Or ensure 7z.exe is in your PATH
```

---

## Support

- GitHub: https://github.com/vitalie-vrabie/scripts
- Documentation: See README_VMBAK_MODULE.md
- Quick Start: See QUICKSTART.md

---

## License

MIT License - See LICENSE.txt for details

Copyright (c) 2025 Vitalie Vrabie

---

## Version History

### Version 1.0.0 (2025)
- Initial release
- Self-extracting PowerShell installer
- WiX-based MSI installer (Windows Installer)
- Complete documentation
- Automatic module registration
- Start Menu integration
- Add/Remove Programs support

---

**Thank you for using PSVMTools!**
