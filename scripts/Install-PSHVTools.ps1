#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Installs PSHVTools PowerShell module.

.DESCRIPTION
    Installs the hvbak module to the system-wide PowerShell modules directory.
    Requires administrator privileges.

.EXAMPLE
    .\Install-PSHVTools.ps1
    
.NOTES
    Run as Administrator to install system-wide.
#>

[CmdletBinding()]
param(
    [switch]$RunHvBak,
    [string]$HvBakArgs = "-NamePattern '*'"
)

$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSHVTools Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Helper: run a PowerShell script in a child process and stream stdout/stderr live
function Run-PowerShellScriptStream {
    param(
        [Parameter(Mandatory=$true)][string]$ScriptPath,
        [Parameter(Mandatory=$false)][string]$Arguments = ''
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $allArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" $Arguments"
    $psi.Arguments = $allArgs
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    try {
        if (-not $proc.Start()) {
            Write-Error "Failed to start PowerShell process for $ScriptPath"
            return $false
        }

        # Asynchronously read output and error streams and forward to host
        $stdOut = $proc.StandardOutput
        $stdErr = $proc.StandardError

        while (-not $proc.HasExited) {
            while (-not $stdOut.EndOfStream) {
                $line = $stdOut.ReadLine()
                if ($line) { Write-Host $line }
            }
            while (-not $stdErr.EndOfStream) {
                $err = $stdErr.ReadLine()
                if ($err) { Write-Host "ERROR: $err" -ForegroundColor Red }
            }
            Start-Sleep -Milliseconds 100
        }

        # Drain any remaining
        try {
            while (-not $stdOut.EndOfStream) { $line = $stdOut.ReadLine(); if ($line) { Write-Host $line } }
        } catch {}
        try {
            while (-not $stdErr.EndOfStream) { $err = $stdErr.ReadLine(); if ($err) { Write-Host "ERROR: $err" -ForegroundColor Red } }
        } catch {}

        if ($proc.ExitCode -ne 0) {
            Write-Error "Script exited with code $($proc.ExitCode)"
            return $false
        }

        return $true
    } finally {
        try { $proc.Dispose() } catch {}
    }
}

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define source files
$SourceFiles = @(
    'hvbak.ps1',
    'pshvtools.psm1',
    'pshvtools.psd1',
    'fix-vhd-acl.ps1',
    'restore-vmbackup.ps1',
    'restore-orphaned-vms.ps1',
    'remove-gpu-partitions.ps1'
)

# Base directory for source files:
# - .ps1 scripts, module manifest (.psd1), and module implementation (.psm1)
#   live next to this installer script in the scripts folder
$ScriptsSourceDir = $ScriptDir

# Verify source files exist
Write-Host "Checking source files..." -ForegroundColor Yellow
$MissingFiles = @()
foreach ($file in $SourceFiles) {
    $FilePath = Join-Path $ScriptsSourceDir $file

    if (-not (Test-Path $FilePath)) {
        $MissingFiles += $file
        Write-Host "  [MISSING] $file" -ForegroundColor Red
    } else {
        Write-Host "  [OK] $file" -ForegroundColor Green
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Host ""
    Write-Error "Missing required files. Cannot continue installation."
    exit 1
}

# Define installation path
$InstallPath = "$env:ProgramFiles\WindowsPowerShell\Modules\pshvtools"

Write-Host ""
Write-Host "Installation path: $InstallPath" -ForegroundColor Cyan

# Create directory if it doesn't exist
if (-not (Test-Path $InstallPath)) {
    Write-Host "Creating module directory..." -ForegroundColor Yellow
    New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
    Write-Host "  [OK] Directory created" -ForegroundColor Green
}

# Copy module files
Write-Host ""
Write-Host "Copying module files..." -ForegroundColor Yellow
try {
    foreach ($file in $SourceFiles) {
        $SourcePath = Join-Path $ScriptsSourceDir $file
        $DestPath = Join-Path $InstallPath $file
        Copy-Item -Path $SourcePath -Destination $DestPath -Force
        Write-Host "  [OK] Copied $file" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to copy files: $_"
    exit 1
}

# Verify installation
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow
try {
    $Module = Test-ModuleManifest -Path "$InstallPath\pshvtools.psd1" -ErrorAction Stop
    Write-Host "  [OK] Module manifest is valid" -ForegroundColor Green
    Write-Host "  [OK] Module version: $($Module.Version)" -ForegroundColor Green
    Write-Host "  [OK] Exported commands: $($Module.ExportedCommands.Keys -join ', ')" -ForegroundColor Green
} catch {
    Write-Warning "Module verification failed: $_"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The module has been installed to:" -ForegroundColor Cyan
Write-Host "  $InstallPath" -ForegroundColor White
Write-Host ""
Write-Host "To use the module, run:" -ForegroundColor Cyan
Write-Host "  Import-Module pshvtools" -ForegroundColor White
Write-Host "  hvbak" -ForegroundColor White
Write-Host ""
Write-Host "Or simply run the commands directly:" -ForegroundColor Cyan
Write-Host "  hvbak -NamePattern '*'" -ForegroundColor White
Write-Host "  hv-bak -NamePattern 'srv-*'" -ForegroundColor White
Write-Host "  hvclone -SourceVmName 'BaseWin11' -NewName 'Win11-Dev01' -DestinationRoot 'D:\\Hyper-V'" -ForegroundColor White
Write-Host "  hv-clone -SourceVmName 'BaseWin11' -NewName 'Win11-Dev02' -DestinationRoot 'D:\\Hyper-V'" -ForegroundColor White
Write-Host "  fix-vhd-acl" -ForegroundColor White
Write-Host ""

# Optionally run hvbak now and stream progress
if ($RunHvBak) {
    Write-Host "Starting hvbak with arguments: $HvBakArgs" -ForegroundColor Cyan
    $scriptToRun = Join-Path $ScriptsSourceDir 'hvbak.ps1'
    if (-not (Test-Path $scriptToRun)) {
        Write-Error "hvbak.ps1 not found at $scriptToRun"
        exit 1
    }

    $ok = Run-PowerShellScriptStream -ScriptPath $scriptToRun -Arguments $HvBakArgs
    if (-not $ok) {
        Write-Error "hvbak failed or was cancelled"
        exit 1
    }
}
