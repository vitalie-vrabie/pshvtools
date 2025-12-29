# vmbak - Hyper-V VM Backup Module

PowerShell module for backing up Hyper-V VMs using checkpoints and 7-Zip compression.

## Installation

### Option 1: Install to User Module Path (Recommended)
```powershell
# Create user module directory if it doesn't exist
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmbak"
New-Item -Path $modulePath -ItemType Directory -Force

# Copy module files
Copy-Item -Path ".\vmbak.psd1" -Destination $modulePath
Copy-Item -Path ".\vmbak.psm1" -Destination $modulePath
Copy-Item -Path ".\vmbak.ps1" -Destination $modulePath

# Import the module
Import-Module vmbak
```

### Option 2: Install to System Module Path (Requires Admin)
```powershell
# Create system module directory if it doesn't exist
$modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\vmbak"
New-Item -Path $modulePath -ItemType Directory -Force

# Copy module files
Copy-Item -Path ".\vmbak.psd1" -Destination $modulePath
Copy-Item -Path ".\vmbak.psm1" -Destination $modulePath
Copy-Item -Path ".\vmbak.ps1" -Destination $modulePath

# Import the module
Import-Module vmbak
```

### Option 3: Add to PowerShell Profile (Auto-load)
```powershell
# Edit your PowerShell profile
notepad $PROFILE

# Add this line to auto-import the module:
Import-Module "C:\path\to\vmbak\vmbak.psd1"
```

## Usage

### Display Help
Run the cmdlet without parameters to see full help and syntax:
```powershell
vmbak
```

Or use PowerShell help commands:
```powershell
Get-Help vmbak
Get-Help vmbak -Full
Get-Help vmbak -Examples
```

### Backup All VMs
```powershell
vmbak -NamePattern "*"
```

### Backup Specific VMs
```powershell
# Backup VMs starting with "srv-"
vmbak -NamePattern "srv-*"

# Backup a single VM
vmbak -NamePattern "MyVM"
```

### Specify Destination
```powershell
vmbak -NamePattern "*" -Destination "D:\backups"
```

### Disable Force Turn Off
```powershell
vmbak -NamePattern "*" -ForceTurnOff:$false
```

## Features

- **Live Backup**: Uses Production checkpoints for minimal downtime
- **Parallel Processing**: Backs up multiple VMs concurrently
- **7-Zip Compression**: Fast compression with multithreading support
- **Automatic Cleanup**: Keeps only the 2 most recent backups per VM
- **Graceful Cancellation**: Ctrl+C support with proper cleanup
- **Progress Tracking**: Real-time progress bars for all VMs
- **Low Priority**: 7-Zip processes run at Idle priority

## Requirements

- Windows PowerShell 5.1 or later
- Hyper-V PowerShell module
- 7-Zip installed (7z.exe in PATH or standard installation location)
- Administrator privileges on Hyper-V host

## Troubleshooting

### Module Not Found
```powershell
# List all available modules
Get-Module -ListAvailable

# Check module paths
$env:PSModulePath -split ';'
```

### Re-import Module After Changes
```powershell
# Remove and re-import
Remove-Module vmbak -ErrorAction SilentlyContinue
Import-Module vmbak -Force
```

## Uninstallation

```powershell
# Remove module from user path
Remove-Item -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmbak" -Recurse -Force

# Or remove from system path
Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\vmbak" -Recurse -Force
```
