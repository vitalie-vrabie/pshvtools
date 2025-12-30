# PSHVTools - Build Guide
## Building Release Packages

---

## Quick Start

### Build GUI EXE Installer

Prerequisite: **Inno Setup 6**

```cmd
Build-InnoSetupInstaller.bat
```

**Output:** `dist/PSHVTools-Setup-1.0.0.exe`

---

## Prerequisites

- Inno Setup 6
- Windows PowerShell 5.1+

---

## Silent Installation (end users)

```cmd
PSHVTools-Setup-1.0.0.exe /VERYSILENT /NORESTART
```

---

## Notes

The repository no longer uses MSBuild packaging scripts. The distributable artifact is the GUI installer EXE built via Inno Setup.
