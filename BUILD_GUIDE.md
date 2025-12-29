# PSVMTools - Installation Guide
## Building and Distributing the Installer Package

---

## ?? Quick Start - Building the Installer

### Build All Installers (Recommended)

```powershell
# From the repository root directory
.\Build-All-Installers.ps1
```

This will create:
- ? Self-extracting PowerShell installer
- ? WiX MSI installer (if WiX is installed)
- ? Complete ZIP package
- ? All files in the `dist` folder

**Output:** `dist/` folder with all installer types

---

## ?? Available Installer Types

### 1. PowerShell Self-Extracting Installer (No Dependencies)

**Best for:** Maximum compatibility, no external dependencies needed

**Files:**
- `dist/PSVMTools-Setup.bat` - Double-click to install
- `dist/PSVMTools-Setup.ps1` - PowerShell installer script
- `dist/PSVMTools-Uninstall.bat` - Uninstaller

**Size:** ~100 KB (all files embedded)

**Build Command:**
```powershell
.\Build-PSVMTools-Installer.ps1
```

**To Install:**
1. Copy `PSVMTools-Setup.bat` to target machine
2. Right-click ? **Run as Administrator**
3. Done!

**Advantages:**
- ? No external dependencies
- ? Single self-contained script
- ? Works on any Windows with PowerShell 5.1+
- ? Easy to distribute via email/USB/network

---

### 2. WiX MSI Installer (Professional)

**Best for:** Professional deployment, traditional Windows installer experience

**File:**
- `dist/PSVMTools-Setup-1.0.0.msi` - Windows Installer (MSI) package

**Size:** ~300 KB

**Prerequisites:**
- Download WiX Toolset from https://wixtoolset.org/releases/
- Or install via Chocolatey: `choco install wixtoolset`

**Build Command:**
```powershell
# Option 1: Using build script
.\Build-All-Installers.ps1

# Option 2: Direct WiX build
.\Build-WixInstaller.ps1

# Option 3: Manual WiX build
candle.exe PSVMTools-Installer.wxs
light.exe -ext WixUIExtension -out dist\PSVMTools-Setup-1.0.0.msi PSVMTools-Installer.wixobj
```

**To Install:**
1. Copy `PSVMTools-Setup-1.0.0.msi` to target machine
2. Double-click the MSI
3. Follow the installation wizard
4. Done!

**Advantages:**
- ? Industry-standard Windows Installer
- ? Full MSI feature support
- ? Transactional installation (rollback on failure)
- ? Add/Remove Programs integration
- ? Group Policy deployment support
- ? Start Menu shortcuts
- ? Silent install: `msiexec /i PSVMTools-Setup-1.0.0.msi /quiet`
- ? Uninstall: `msiexec /x PSVMTools-Setup-1.0.0.msi /quiet`

---

### 3. Complete Package (ZIP)

**Best for:** Distribution that includes all methods and documentation

**File:**
- `dist/PSVMTools-1.0.0-Complete.zip`

**Contents:**
- All module files
- PowerShell installer
- Documentation
- License

**To Use:**
1. Extract ZIP on target machine
2. Choose installation method:
   - Run `installer/PSVMTools-Setup.bat` (PowerShell)
   - Or manually run `Install-vmbak.ps1`

---

## ??? Build Options

### Clean Build
```powershell
# Remove old builds and start fresh
.\Build-All-Installers.ps1 -CleanFirst
```

### Skip WiX (Faster Build)
```powershell
# Build only PowerShell installer
.\Build-All-Installers.ps1 -SkipWix
```

### Build Only PowerShell Installer
```powershell
.\Build-PSVMTools-Installer.ps1
```

### Custom Output Path
```powershell
.\Build-PSVMTools-Installer.ps1 -OutputPath "C:\MyBuilds"
```

---

## ?? Installation Comparison

| Feature | PowerShell Installer | WiX MSI Installer | Manual Install |
|---------|---------------------|------------------|----------------|
| **File Size** | ~100 KB | ~300 KB | Varies |
| **Dependencies** | None | None | None |
| **Admin Required** | Yes | Yes | Yes |
| **Start Menu** | No | Yes | No |
| **Add/Remove Programs** | No | Yes | No |
| **Silent Install** | Yes (`-Action Install`) | Yes (`/quiet`) | Yes |
| **Distribution** | 3 files | 1 file | Multiple files |
| **Build Requirements** | None | WiX | None |

---

## ?? Usage After Installation

Regardless of installation method, after installation:

```powershell
# Display help
vmbak

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

## ??? Uninstallation

### PowerShell Installer
```powershell
# Run uninstaller
.\PSVMTools-Uninstall.bat
```

### MSI Installer
- Use **Add/Remove Programs** in Windows Settings
- Or run the uninstaller from Start Menu
- Or use silent uninstall: `msiexec /x PSVMTools-Setup-1.0.0.msi /quiet`

### Manual
```powershell
.\Uninstall-vmbak.ps1 -Scope System
```

---

## ?? Silent Installation (Automated Deployment)

### PowerShell Installer
```powershell
# Silent system-wide install
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "PSVMTools-Setup.ps1" -Action Install -Scope System

# Silent user install
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "PSVMTools-Setup.ps1" -Action Install -Scope User
```

### MSI Installer
```cmd
# Silent install
msiexec /i PSVMTools-Setup-1.0.0.msi /quiet

# Silent uninstall
msiexec /x PSVMTools-Setup-1.0.0.msi /quiet
```

---

## ?? Distribution Best Practices

### For IT Department / Enterprise
**Recommended:** MSI Installer
- Single file distribution
- Professional UI
- Add/Remove Programs integration
- Group Policy deployment friendly

### For GitHub / Open Source
**Recommended:** Complete ZIP Package
- Includes all installation methods
- Users can choose their preferred method
- Full documentation included

### For Quick Sharing / Testing
**Recommended:** PowerShell Self-Extractor
- Minimal file count
- No dependencies
- Easy to send via email/Slack

---

## ?? Testing the Installer

### Test PowerShell Installer
```powershell
# Build
.\Build-PSVMTools-Installer.ps1

# Test install (as Admin)
cd dist
.\PSVMTools-Setup.bat

# Verify
vmbak

# Test uninstall
.\PSVMTools-Uninstall.bat
```

### Test MSI Installer
```powershell
# Build
.\Build-WixInstaller.ps1

# Test install
cd dist
.\PSVMTools-Setup-1.0.0.msi

# Verify
vmbak

# Test uninstall (from Add/Remove Programs or)
msiexec /x PSVMTools-Setup-1.0.0.msi /quiet
```

---

## ?? Troubleshooting Build Issues

### "WiX not found"
**Solution:** 
- Install WiX Toolset from https://wixtoolset.org/releases/
- Or use `-SkipWix` flag to skip MSI build

### "File not found" errors
**Solution:**
- Run build from repository root directory
- Ensure all required files are present
- Try clean build: `-CleanFirst`

### "Access denied" during build
**Solution:**
- Close any files in `dist` folder
- Run as Administrator if building to protected location

### PowerShell execution policy errors
**Solution:**
```powershell
# Allow script execution
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## ?? Version Updates

When updating to a new version:

1. Update version in `vmbak.psd1`:
   ```powershell
   ModuleVersion = '1.1.0'
   ```

2. Update version in `PSVMTools-Installer.nsi`:
   ```nsis
   VIProductVersion "1.1.0.0"
   OutFile "dist\PSVMTools-Setup-1.1.0.exe"
   ```

3. Update version in build scripts

4. Rebuild all installers:
   ```powershell
   .\Build-All-Installers.ps1 -CleanFirst
   ```

---

## ?? Summary

**Quick Command to Build Everything:**
```powershell
.\Build-All-Installers.ps1
```

**Output Location:**
```
dist/
??? PSVMTools-Setup.ps1           # Self-extracting installer
??? PSVMTools-Setup.bat           # Installer launcher
??? PSVMTools-Uninstall.bat       # Uninstaller
??? PSVMTools-Setup-1.0.0.msi     # MSI installer (if built)
??? PSVMTools-1.0.0-Complete.zip  # Complete package
```

**Distribute any one of these based on your needs!** ??

---

## ?? Additional Resources

- **Module Documentation:** README_VMBAK_MODULE.md
- **Quick Start Guide:** QUICKSTART.md
- **Package Details:** PACKAGE_README.md
- **License:** LICENSE.txt

---

**Need help?** Check the GitHub repository: https://github.com/vitalie-vrabie/scripts
