# Install-vmbak.ps1
# Installation script for vmbak PowerShell module

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('User', 'System')]
    [string]$Scope = 'User'
)

$ErrorActionPreference = 'Stop'

Write-Host "Installing vmbak module..." -ForegroundColor Cyan

# Determine installation path based on scope
if ($Scope -eq 'System') {
    $modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\vmbak"
    
    # Check for admin rights
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Error "Installing to System scope requires Administrator privileges. Please run as Administrator or use -Scope User"
        exit 1
    }
} else {
    $modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmbak"
}

Write-Host "Installation path: $modulePath" -ForegroundColor Yellow

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check required files
$requiredFiles = @('vmbak.psd1', 'vmbak.psm1', 'vmbak.ps1')
foreach ($file in $requiredFiles) {
    $filePath = Join-Path -Path $scriptDir -ChildPath $file
    if (-not (Test-Path $filePath)) {
        Write-Error "Required file not found: $file"
        exit 1
    }
}

# Create module directory
try {
    if (Test-Path $modulePath) {
        Write-Host "Removing existing installation..." -ForegroundColor Yellow
        Remove-Item -Path $modulePath -Recurse -Force
    }
    
    New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
    Write-Host "Created module directory: $modulePath" -ForegroundColor Green
} catch {
    Write-Error "Failed to create module directory: $_"
    exit 1
}

# Copy files
try {
    foreach ($file in $requiredFiles) {
        $source = Join-Path -Path $scriptDir -ChildPath $file
        $destination = Join-Path -Path $modulePath -ChildPath $file
        Copy-Item -Path $source -Destination $destination -Force
        Write-Host "Copied: $file" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to copy module files: $_"
    exit 1
}

# Import module
try {
    Remove-Module vmbak -ErrorAction SilentlyContinue
    Import-Module vmbak -Force
    Write-Host "`nModule installed and imported successfully!" -ForegroundColor Green
} catch {
    Write-Warning "Module files copied but import failed: $_"
    Write-Host "You can manually import with: Import-Module vmbak" -ForegroundColor Yellow
}

# Display usage info
Write-Host "`n=== Usage ===" -ForegroundColor Cyan
Write-Host "Display help:     vmbak" -ForegroundColor White
Write-Host "Backup all VMs:   vmbak -NamePattern '*'" -ForegroundColor White
Write-Host "Get full help:    Get-Help vmbak -Full" -ForegroundColor White

Write-Host "`nInstallation complete!" -ForegroundColor Green
