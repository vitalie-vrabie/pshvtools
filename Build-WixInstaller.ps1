# Build-WixInstaller.ps1
# Builds the MSI installer using WiX Toolset

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\dist",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipWixCheck
)

$ErrorActionPreference = 'Stop'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PSVMTools MSI Installer Builder" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check for WiX Toolset
if (-not $SkipWixCheck) {
    Write-Host "Checking for WiX Toolset..." -ForegroundColor Yellow
    
    $wixPath = $null
    $possiblePaths = @(
        "${env:ProgramFiles}\WiX Toolset v3.11\bin",
        "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin",
        "${env:WIX}bin"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path (Join-Path $path "candle.exe")) {
            $wixPath = $path
            break
        }
    }
    
    if (-not $wixPath) {
        # Try to find in PATH
        $candleCmd = Get-Command candle.exe -ErrorAction SilentlyContinue
        if ($candleCmd) {
            $wixPath = Split-Path -Parent $candleCmd.Path
        }
    }
    
    if (-not $wixPath) {
        Write-Host "`n? WiX Toolset not found!" -ForegroundColor Red
        Write-Host "`nPlease install WiX Toolset v3.11 or later from:" -ForegroundColor Yellow
        Write-Host "https://wixtoolset.org/releases/" -ForegroundColor White
        Write-Host "`nOr use Chocolatey: choco install wixtoolset" -ForegroundColor White
        exit 1
    }
    
    Write-Host "  ? Found WiX Toolset at: $wixPath" -ForegroundColor Green
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    Write-Host "Created output directory: $OutputPath" -ForegroundColor Green
}

# Required files
$requiredFiles = @(
    'vmbak.ps1',
    'vmbak.psm1',
    'vmbak.psd1',
    'QUICKSTART.md',
    'PSVMTools-Installer.wxs'
)

Write-Host "`nValidating files..." -ForegroundColor Yellow
foreach ($file in $requiredFiles) {
    $filePath = Join-Path -Path $scriptDir -ChildPath $file
    if (-not (Test-Path $filePath)) {
        Write-Error "Required file not found: $file"
        exit 1
    }
    Write-Host "  ? $file" -ForegroundColor Green
}

# Create placeholder icon if it doesn't exist
$iconPath = Join-Path -Path $scriptDir -ChildPath "icon.ico"
if (-not (Test-Path $iconPath)) {
    Write-Host "`n??  Note: icon.ico not found, using default Windows icon" -ForegroundColor Yellow
    # WiX will use default icon if file is missing
}

# Create License.rtf from LICENSE.txt if it doesn't exist
$licenseRtf = Join-Path -Path $scriptDir -ChildPath "License.rtf"
$licenseTxt = Join-Path -Path $scriptDir -ChildPath "LICENSE.txt"

if (-not (Test-Path $licenseRtf) -and (Test-Path $licenseTxt)) {
    Write-Host "`nConverting LICENSE.txt to License.rtf..." -ForegroundColor Yellow
    
    $licenseContent = Get-Content $licenseTxt -Raw
    $rtfContent = @"
{\rtf1\ansi\deff0
{\fonttbl{\f0 Courier New;}}
\f0\fs20
$($licenseContent -replace "`n", "\par`n")
}
"@
    
    $rtfContent | Out-File -FilePath $licenseRtf -Encoding ASCII
    Write-Host "  ? Created License.rtf" -ForegroundColor Green
}

# Build with WiX
Write-Host "`nBuilding MSI installer..." -ForegroundColor Yellow

$wxsFile = Join-Path -Path $scriptDir -ChildPath "PSVMTools-Installer.wxs"
$wixobjFile = Join-Path -Path $OutputPath -ChildPath "PSVMTools-Installer.wixobj"
$msiFile = Join-Path -Path $OutputPath -ChildPath "PSVMTools-Setup-1.0.0.msi"

try {
    # Step 1: Compile with candle.exe
    Write-Host "  Step 1/2: Compiling WXS to WIXOBJ..." -ForegroundColor Cyan
    
    $candleExe = Join-Path $wixPath "candle.exe"
    $candleArgs = @(
        "-nologo",
        "-out", $wixobjFile,
        $wxsFile
    )
    
    & $candleExe $candleArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Candle.exe failed with exit code: $LASTEXITCODE"
    }
    
    Write-Host "    ? Compilation successful" -ForegroundColor Green
    
    # Step 2: Link with light.exe
    Write-Host "  Step 2/2: Linking to MSI..." -ForegroundColor Cyan
    
    $lightExe = Join-Path $wixPath "light.exe"
    $lightArgs = @(
        "-nologo",
        "-ext", "WixUIExtension",
        "-cultures:en-us",
        "-out", $msiFile,
        $wixobjFile
    )
    
    & $lightExe $lightArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Light.exe failed with exit code: $LASTEXITCODE"
    }
    
    Write-Host "    ? Linking successful" -ForegroundColor Green
    
    # Cleanup intermediate files
    if (Test-Path $wixobjFile) {
        Remove-Item $wixobjFile -Force
    }
    
} catch {
    Write-Host "`n? Build failed: $_" -ForegroundColor Red
    exit 1
}

# Success!
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  MSI Build Successful! ?" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

if (Test-Path $msiFile) {
    $msiSize = [Math]::Round((Get-Item $msiFile).Length / 1KB, 2)
    Write-Host "`nOutput:" -ForegroundColor Cyan
    Write-Host "  File: $msiFile" -ForegroundColor White
    Write-Host "  Size: $msiSize KB" -ForegroundColor White
}

Write-Host "`nInstallation:" -ForegroundColor Cyan
Write-Host "  Interactive: Double-click the MSI file" -ForegroundColor White
Write-Host "  Silent:      msiexec /i PSVMTools-Setup-1.0.0.msi /quiet" -ForegroundColor White
Write-Host "  Uninstall:   msiexec /x PSVMTools-Setup-1.0.0.msi /quiet" -ForegroundColor White
Write-Host ""
