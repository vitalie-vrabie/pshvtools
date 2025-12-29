# Uninstall-vmbak.ps1
# Uninstallation script for vmbak PowerShell module

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('User', 'System', 'Both')]
    [string]$Scope = 'User'
)

$ErrorActionPreference = 'Stop'

Write-Host "Uninstalling vmbak module..." -ForegroundColor Cyan

function Remove-ModuleInstallation {
    param([string]$Path)
    
    if (Test-Path $Path) {
        try {
            # Remove module from memory first
            Remove-Module vmbak -ErrorAction SilentlyContinue
            
            Write-Host "Removing: $Path" -ForegroundColor Yellow
            Remove-Item -Path $Path -Recurse -Force
            Write-Host "Removed: $Path" -ForegroundColor Green
            return $true
        } catch {
            Write-Warning "Failed to remove $Path : $_"
            return $false
        }
    } else {
        Write-Host "Not found: $Path" -ForegroundColor Gray
        return $false
    }
}

$removed = $false

# Remove from User scope
if ($Scope -in @('User', 'Both')) {
    $userPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmbak"
    $removed = Remove-ModuleInstallation -Path $userPath -or $removed
}

# Remove from System scope
if ($Scope -in @('System', 'Both')) {
    $systemPath = "$env:ProgramFiles\WindowsPowerShell\Modules\vmbak"
    
    # Check for admin rights
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning "Removing from System scope requires Administrator privileges."
        Write-Host "Run as Administrator or use -Scope User" -ForegroundColor Yellow
    } else {
        $removed = Remove-ModuleInstallation -Path $systemPath -or $removed
    }
}

if ($removed) {
    Write-Host "`nUninstallation complete!" -ForegroundColor Green
} else {
    Write-Host "`nNo installations found to remove." -ForegroundColor Yellow
}
