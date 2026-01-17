[CmdletBinding()]
param(
    [string]$IsccPath = $env:INNO_SETUP_PATH,
    [string]$IssFile = $env:INNO_SETUP_ISS
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($IsccPath)) {
    $IsccPath = "C:\Program Files (x86)\Inno Setup 6"
}

if ([string]::IsNullOrWhiteSpace($IssFile)) {
    $candidate = Join-Path $PSScriptRoot 'installer\PSHVTools-Installer.iss'
    if (Test-Path -LiteralPath $candidate) {
        $IssFile = $candidate
    } else {
        $IssFile = Join-Path $PSScriptRoot 'PSHVTools-Installer.iss'
    }
}

$isccExe = Join-Path $IsccPath 'ISCC.exe'

if (-not (Test-Path -LiteralPath $isccExe)) {
    throw "ISCC.exe not found at '$isccExe'. Provide -IsccPath or set INNO_SETUP_PATH."
}

if (-not (Test-Path -LiteralPath $IssFile)) {
    throw "ISS file not found at '$IssFile'. Provide -IssFile or set INNO_SETUP_ISS."
}

& $isccExe $IssFile
