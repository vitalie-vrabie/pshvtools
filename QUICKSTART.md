# Quick Start Guide - vmbak cmdlet

## Installation (One-Time Setup)

Run the installation script from the repository directory:

```powershell
# Install for current user (recommended)
.\Install-vmbak.ps1

# OR install system-wide (requires Administrator)
.\Install-vmbak.ps1 -Scope System
```

## Usage

### Display Help and Syntax
Simply run the cmdlet without parameters:

```powershell
vmbak
```

This will display the full help documentation including:
- Synopsis
- Description
- Parameters
- Examples
- Notes

### Quick Examples

```powershell
# Get detailed help
Get-Help vmbak -Full

# See only examples
Get-Help vmbak -Examples

# Backup all VMs
vmbak -NamePattern "*"

# Backup specific VMs
vmbak -NamePattern "MyVM"
vmbak -NamePattern "srv-*"

# Specify custom destination
vmbak -NamePattern "*" -Destination "D:\backups"

# Disable force turn off
vmbak -NamePattern "*" -ForceTurnOff:$false
```

## Testing the Installation

After installation, verify the module is available:

```powershell
# Check if module is loaded
Get-Module vmbak

# If not loaded, import it
Import-Module vmbak

# Verify the cmdlet is available
Get-Command vmbak

# Display help
vmbak
```

## Uninstallation

To remove the module:

```powershell
# Uninstall from user scope
.\Uninstall-vmbak.ps1

# Uninstall from system scope (requires Administrator)
.\Uninstall-vmbak.ps1 -Scope System

# Uninstall from both locations
.\Uninstall-vmbak.ps1 -Scope Both
```

## Auto-load Module on Startup (Optional)

To automatically load the module when you start PowerShell:

```powershell
# Edit your PowerShell profile
notepad $PROFILE

# Add this line:
Import-Module vmbak

# Save and close the file
```

## Troubleshooting

### "vmbak" command not found

```powershell
# Verify installation
Get-Module vmbak -ListAvailable

# If found, import manually
Import-Module vmbak

# If not found, reinstall
.\Install-vmbak.ps1
```

### Module not loading automatically

```powershell
# Check your module path
$env:PSModulePath -split ';'

# Verify module files exist in one of these paths
```

### Need to refresh module after changes

```powershell
# Remove and re-import
Remove-Module vmbak -ErrorAction SilentlyContinue
Import-Module vmbak -Force
```
