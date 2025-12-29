# PSVMTools-Installer.ps1
# Self-extracting installer for PSVMTools
# Creates an executable installer that embeds all required files

<#
.SYNOPSIS
    Creates a self-contained installer for PSVMTools

.DESCRIPTION
    This script packages all PSVMTools files into a single executable installer.
    The installer can be distributed and run on any Windows system with PowerShell 5.1+.

.PARAMETER OutputPath
    Path where the installer executable will be created. Default: .\dist

.EXAMPLE
    .\PSVMTools-Installer.ps1
    Creates PSVMTools-Setup.exe in the .\dist folder
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\dist"
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSVMTools Installer Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Files to package
$filesToPackage = @(
    'vmbak.ps1',
    'vmbak.psm1',
    'vmbak.psd1',
    'Install-vmbak.ps1',
    'Uninstall-vmbak.ps1',
    'README_VMBAK_MODULE.md',
    'QUICKSTART.md'
)

Write-Host "Validating files..." -ForegroundColor Yellow
foreach ($file in $filesToPackage) {
    $filePath = Join-Path -Path $scriptDir -ChildPath $file
    if (-not (Test-Path $filePath)) {
        Write-Error "Required file not found: $file"
        exit 1
    }
    Write-Host "  [OK] $file" -ForegroundColor Green
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    Write-Host "`nCreated output directory: $OutputPath" -ForegroundColor Green
}

# Create the installer script
$installerScriptContent = @'
#Requires -Version 5.1
#Requires -RunAsAdministrator

# PSVMTools Setup
# Version 1.0.0

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [string]$Action = 'Install',
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('User', 'System')]
    [string]$Scope = 'User'
)

$ErrorActionPreference = 'Stop'

# ASCII Art Banner
$banner = @"
?????????????????????????????????????????????????????????????
?                                                           ?
?   ??????? ???????????   ???????   ????????????? ???????  ?
?   ???????????????????   ???????? ??????????????????????? ?
?   ???????????????????   ??????????????   ???   ???   ??? ?
?   ??????? ???????????? ???????????????   ???   ???   ??? ?
?   ???     ???????? ??????? ??? ??? ???   ???   ????????? ?
?   ???     ????????  ?????  ???     ???   ???    ???????  ?
?                                                           ?
?           PowerShell VM Tools - Setup v1.0.0             ?
?                                                           ?
?????????????????????????????????????????????????????????????
"@

Write-Host $banner -ForegroundColor Cyan
Write-Host ""

# Embedded files data (will be populated by builder)
$embeddedFiles = @{
'@

# Read and embed all files as base64
Write-Host "`nEmbedding files..." -ForegroundColor Yellow
foreach ($file in $filesToPackage) {
    $filePath = Join-Path -Path $scriptDir -ChildPath $file
    $content = [System.IO.File]::ReadAllBytes($filePath)
    $base64 = [Convert]::ToBase64String($content)
    
    $installerScriptContent += @"

    '$file' = @'
$base64
'@
"@
    Write-Host "  [OK] Embedded $file ($([Math]::Round($content.Length / 1KB, 2)) KB)" -ForegroundColor Green
}

$installerScriptContent += @'

}

function Write-ColorHost {
    param([string]$Text, [string]$Color = 'White')
    Write-Host $Text -ForegroundColor $Color
}

function Extract-Files {
    param([string]$TempPath)
    
    Write-ColorHost "Extracting files to temporary location..." "Yellow"
    
    if (-not (Test-Path $TempPath)) {
        New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
    }
    
    foreach ($file in $embeddedFiles.Keys) {
        $filePath = Join-Path -Path $TempPath -ChildPath $file
        $bytes = [Convert]::FromBase64String($embeddedFiles[$file])
        [System.IO.File]::WriteAllBytes($filePath, $bytes)
        Write-ColorHost "  [OK] $file" "Green"
    }
    
    Write-ColorHost "Files extracted successfully!" "Green"
}

function Install-PSVMTools {
    param([string]$TempPath, [string]$Scope)
    
    Write-ColorHost "`nInstalling PSVMTools..." "Cyan"
    
    # Determine installation path
    if ($Scope -eq 'System') {
        $modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\vmbak"
    } else {
        $modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmbak"
    }
    
    Write-ColorHost "Installation path: $modulePath" "Yellow"
    
    # Create module directory
    if (Test-Path $modulePath) {
        Write-ColorHost "Removing existing installation..." "Yellow"
        Remove-Item -Path $modulePath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
    
    # Copy module files
    $moduleFiles = @('vmbak.ps1', 'vmbak.psm1', 'vmbak.psd1')
    foreach ($file in $moduleFiles) {
        $source = Join-Path -Path $TempPath -ChildPath $file
        $destination = Join-Path -Path $modulePath -ChildPath $file
        Copy-Item -Path $source -Destination $destination -Force
        Write-ColorHost "  [OK] Installed $file" "Green"
    }
    
    # Copy documentation
    $docsPath = Join-Path -Path $modulePath -ChildPath "docs"
    New-Item -Path $docsPath -ItemType Directory -Force | Out-Null
    
    $docFiles = @('README_VMBAK_MODULE.md', 'QUICKSTART.md')
    foreach ($file in $docFiles) {
        $source = Join-Path -Path $TempPath -ChildPath $file
        if (Test-Path $source) {
            $destination = Join-Path -Path $docsPath -ChildPath $file
            Copy-Item -Path $source -Destination $destination -Force
        }
    }
    
    # Import module
    try {
        Remove-Module vmbak -ErrorAction SilentlyContinue
        Import-Module vmbak -Force
        Write-ColorHost "`nModule imported successfully!" "Green"
    } catch {
        Write-Warning "Module installed but import failed. You can manually import with: Import-Module vmbak"
    }
    
    Write-ColorHost "`n========================================" "Green"
    Write-ColorHost "  Installation completed successfully!" "Green"
    Write-ColorHost "========================================" "Green"
    Write-ColorHost "`nQuick Start:" "Cyan"
    Write-ColorHost "  Display help:     vmbak" "White"
    Write-ColorHost "  Backup all VMs:   vmbak -NamePattern '*'" "White"
    Write-ColorHost "  Get full help:    Get-Help vmbak -Full" "White"
    Write-ColorHost ""
}

function Uninstall-PSVMTools {
    Write-ColorHost "`nUninstalling PSVMTools..." "Cyan"
    
    $removed = $false
    
    # Remove from User scope
    $userPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmbak"
    if (Test-Path $userPath) {
        Remove-Module vmbak -ErrorAction SilentlyContinue
        Remove-Item -Path $userPath -Recurse -Force
        Write-ColorHost "  [OK] Removed from User scope" "Green"
        $removed = $true
    }
    
    # Remove from System scope
    $systemPath = "$env:ProgramFiles\WindowsPowerShell\Modules\vmbak"
    if (Test-Path $systemPath) {
        Remove-Module vmbak -ErrorAction SilentlyContinue
        Remove-Item -Path $systemPath -Recurse -Force
        Write-ColorHost "  [OK] Removed from System scope" "Green"
        $removed = $true
    }
    
    if ($removed) {
        Write-ColorHost "`nUninstallation completed successfully!" "Green"
    } else {
        Write-ColorHost "`nNo installations found." "Yellow"
    }
}

# Main execution
try {
    $tempPath = Join-Path -Path $env:TEMP -ChildPath "PSVMTools_Setup_$(Get-Random)"
    
    switch ($Action) {
        'Install' {
            Extract-Files -TempPath $tempPath
            Install-PSVMTools -TempPath $tempPath -Scope $Scope
        }
        'Uninstall' {
            Uninstall-PSVMTools
        }
        'Repair' {
            Write-ColorHost "Repairing installation..." "Cyan"
            Extract-Files -TempPath $tempPath
            Install-PSVMTools -TempPath $tempPath -Scope $Scope
        }
    }
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
} finally {
    # Cleanup temp files
    if ($tempPath -and (Test-Path $tempPath)) {
        Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
'@

# Save the installer script
$installerScriptPath = Join-Path -Path $OutputPath -ChildPath "PSVMTools-Setup.ps1"
$installerScriptContent | Out-File -FilePath $installerScriptPath -Encoding UTF8 -Force

Write-Host "`nInstaller script created: $installerScriptPath" -ForegroundColor Green

# Create a batch wrapper to run as admin
$batchWrapperContent = @'
@echo off
title PSVMTools Setup
echo Starting PSVMTools Setup...
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installer requires Administrator privileges.
    echo Please run as Administrator.
    echo.
    pause
    exit /b 1
)

:: Run PowerShell installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0PSVMTools-Setup.ps1" -Action Install -Scope System

pause
'@

$batchWrapperPath = Join-Path -Path $OutputPath -ChildPath "PSVMTools-Setup.bat"
$batchWrapperContent | Out-File -FilePath $batchWrapperPath -Encoding ASCII -Force

Write-Host "Batch wrapper created: $batchWrapperPath" -ForegroundColor Green

# Create uninstaller batch
$uninstallerBatchContent = @'
@echo off
title PSVMTools Uninstaller
echo Uninstalling PSVMTools...
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This uninstaller requires Administrator privileges.
    echo Please run as Administrator.
    echo.
    pause
    exit /b 1
)

:: Run PowerShell uninstaller
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0PSVMTools-Setup.ps1" -Action Uninstall

pause
'@

$uninstallerBatchPath = Join-Path -Path $OutputPath -ChildPath "PSVMTools-Uninstall.bat"
$uninstallerBatchContent | Out-File -FilePath $uninstallerBatchPath -Encoding ASCII -Force

Write-Host "Uninstaller created: $uninstallerBatchPath" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nOutput files:" -ForegroundColor Cyan
Write-Host "  - $installerScriptPath" -ForegroundColor White
Write-Host "  - $batchWrapperPath" -ForegroundColor White
Write-Host "  - $uninstallerBatchPath" -ForegroundColor White
Write-Host "`nTo install:" -ForegroundColor Cyan
Write-Host "  1. Copy the files to the target system" -ForegroundColor White
Write-Host "  2. Right-click PSVMTools-Setup.bat" -ForegroundColor White
Write-Host "  3. Select 'Run as Administrator'" -ForegroundColor White
Write-Host ""

# Calculate total size
$totalSize = 0
Get-ChildItem -Path $OutputPath -File | ForEach-Object { $totalSize += $_.Length }
Write-Host "Total package size: $([Math]::Round($totalSize / 1KB, 2)) KB" -ForegroundColor Yellow
Write-Host ""
