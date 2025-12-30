# PSHVTools - Clean Workspace

## ? Workspace Cleaned and Optimized

All migration documentation, temporary files, and PowerShell installer outputs have been removed. The workspace now contains only essential files for building the GUI EXE installer.

---

## ?? Essential Files

### Core Module Files
```
hvbak.ps1                    # Main backup script
hvbak.psm1                   # PowerShell module
hvbak.psd1                   # Module manifest
```

### Installation Scripts
```
Install-PSHVTools.ps1        # PowerShell installer (for manual use)
Uninstall-PSHVTools.ps1      # PowerShell uninstaller
```

### Build System

**MSBuild Project:**
```
PSHVTools.csproj             # MSBuild project file
```

**GUI Installer Build:**
```
Build-InnoSetupInstaller.bat # Build GUI EXE installer ?
PSHVTools-Installer.iss      # Inno Setup script
```

**PowerShell Installer Build (optional):**
```
Build-Release.bat            # Build PowerShell installer packages
Build-Installer.bat          # Build PowerShell installer only
Create-InstallerScript.ps1   # Generates PowerShell installer scripts
```

### Documentation
```
README.md                    # Main project documentation
QUICKSTART.md                # Quick start guide for users
BUILD_GUIDE.md               # Complete build instructions
INNO_SETUP_INSTALLER.md      # GUI installer documentation
PROJECT_SUMMARY.md           # Project overview
RELEASE_NOTES_v1.0.0.md      # Release notes
README_HVBAK_MODULE.md       # Module documentation
LICENSE.txt                  # MIT license
WORKSPACE_CLEAN.md           # This file
```

### Utility Scripts
```
vm-fix-acl.ps1              # ACL fix utility
```

---

## ?? Build Command

### Build GUI EXE Installer (Primary)
```cmd
Build-InnoSetupInstaller.bat
```
**Output:** `dist/PSHVTools-Setup-1.0.0.exe` (1.88 MB)

---

## ?? Distribution Package

After building, you'll have:

**GUI EXE Installer** - `dist/PSHVTools-Setup-1.0.0.exe`
- Professional wizard interface
- System requirements checking
- Windows integration
- Silent installation support
- 1.88 MB

---

## ??? Files Removed

**Migration/Temporary Documentation (10 files):**
- All WiX migration documentation
- Rename summaries
- Temporary build files

**PowerShell Installer Outputs:**
- `dist/PSHVTools-Setup-1.0.0.zip` - PowerShell installer ZIP
- `dist/PSHVTools-Setup-1.0.0/` - PowerShell installer folder
- `release/` - Entire folder removed

**Result:** Only the GUI EXE installer remains in `dist/`

---

## ? Current Status

**Workspace:** Clean and focused on GUI installer  
**Build System:** GUI EXE installer only  
**Output:** Single professional installer (1.88 MB)  
**Status:** Production ready ?

---

## ?? Quick Start

### Build GUI Installer:
```cmd
Build-InnoSetupInstaller.bat
```

### Test Installation:
```cmd
dist\PSHVTools-Setup-1.0.0.exe
```

### Create GitHub Release:
1. Go to: https://github.com/vitalie-vrabie/pshvtools/releases
2. Create new release: v1.0.0
3. Upload: `dist/PSHVTools-Setup-1.0.0.exe`

---

**Workspace is now optimized for building the professional GUI EXE installer!** ?
