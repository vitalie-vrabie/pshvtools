<#
.SYNOPSIS
  Clone a Hyper-V VM into a new VM with a new name.

.DESCRIPTION
  Exports the source VM to a temporary folder, then imports it using Copy mode with a new VM Id
  and renames the imported VM to NewName.

.PARAMETER SourceVmName
  Name of the existing VM to clone.

.PARAMETER NewName
  Name of the new cloned VM. If omitted, the name is derived from the last segment of DestinationRoot.

.PARAMETER DestinationRoot
  Folder where the new VM files will be stored. When NewName is omitted, DestinationRoot can point
  directly to the new VM folder (the VM name is taken from the folder name).

.PARAMETER VmRoot
  Folder containing all VMs. The new VM will be created under VmRoot\<NewName>.

.PARAMETER TempFolder
  Temporary folder used for the Hyper-V export step.

.PARAMETER Force
  If a VM named NewName already exists, remove it before importing.

.EXAMPLE
  .\hvclone.ps1 -SourceVmName 'BaseWin11' -NewName 'Win11-Dev01' -DestinationRoot 'D:\Hyper-V'

.EXAMPLE
  .\hvclone.ps1 'BaseWin11' 'Win11-Dev02' 'E:\hvclone-temp'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceVmName,

    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$NewName,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$DestinationRoot,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$VmRoot,

    [Parameter(Mandatory = $false, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$TempFolder = "$env:TEMP\hvclone",

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest

function Resolve-UncPathIfMapped {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $qualifier = Split-Path -Path $Path -Qualifier
    if ([string]::IsNullOrWhiteSpace($qualifier)) {
        return $Path
    }

    $driveName = $qualifier.TrimEnd('\').TrimEnd(':')
    $psDrive = Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue
    if (-not $psDrive -or -not $psDrive.DisplayRoot) {
        return $Path
    }

    $relative = $Path.Substring($qualifier.Length).TrimStart('\')
    if ([string]::IsNullOrWhiteSpace($relative)) {
        return $psDrive.DisplayRoot
    }

    return (Join-Path -Path $psDrive.DisplayRoot -ChildPath $relative)
}

try {
    Import-Module Hyper-V -ErrorAction Stop | Out-Null
} catch {
    throw "Hyper-V module is required. Run on a Hyper-V host with the Hyper-V PowerShell module installed. $_"
}

if ([string]::IsNullOrWhiteSpace($DestinationRoot) -and -not [string]::IsNullOrWhiteSpace($NewName)) {
    $looksLikePath = $false
    try {
        if ([System.IO.Path]::IsPathRooted($NewName)) {
            $looksLikePath = $true
        } elseif ($NewName -match '[\\/]') {
            $looksLikePath = $true
        }
    } catch {}

    if ($looksLikePath) {
        $DestinationRoot = $NewName
        $NewName = $null
    }
}

if (-not [string]::IsNullOrWhiteSpace($DestinationRoot) -and [string]::IsNullOrWhiteSpace($NewName)) {
    $NewName = Split-Path -Path $DestinationRoot -Leaf
    $DestinationRoot = Split-Path -Path $DestinationRoot -Parent
}

if ([string]::IsNullOrWhiteSpace($NewName)) {
    throw "NewName is required. Provide -NewName or use a DestinationRoot that includes the new VM folder name."
}

if ($SourceVmName -eq $NewName) {
    throw "NewName must be different from SourceVmName."
}

$src = Get-VM -Name $SourceVmName -ErrorAction Stop

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $defaultRoot = $null
    try {
        $vmHost = Get-VMHost -ErrorAction Stop
        if ($vmHost.VirtualMachinePath) {
            $defaultRoot = $vmHost.VirtualMachinePath
        }
    } catch {}

    if (-not $defaultRoot -and $src.Path) {
        try {
            $item = Get-Item -LiteralPath $src.Path -ErrorAction Stop
            if ($item.PSIsContainer) {
                $defaultRoot = $item.FullName
            } else {
                $defaultRoot = $item.Directory.FullName
            }
        } catch {
            $defaultRoot = Split-Path -Path $src.Path -Parent
        }
    }

    $DestinationRoot = $defaultRoot
}

if (-not [string]::IsNullOrWhiteSpace($VmRoot)) {
    $DestinationRoot = $VmRoot
}

if (-not [string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $DestinationRoot = Resolve-UncPathIfMapped -Path $DestinationRoot
}

$TempFolder = Resolve-UncPathIfMapped -Path $TempFolder

if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    throw "DestinationRoot is required. Use -DestinationRoot to specify the target VM storage root."
}

$existing = Get-VM -Name $NewName -ErrorAction SilentlyContinue
if ($existing -and -not $Force) {
    throw "A VM named '$NewName' already exists. Use -Force to remove it before cloning."
}

if ($existing -and $Force) {
    try {
        if ($existing.State -ne 'Off') {
            Stop-VM -VM $existing -TurnOff -Force -ErrorAction SilentlyContinue
        }
    } catch {}

    Remove-VM -VM $existing -Force -ErrorAction Stop
}

$destVmRoot = Join-Path -Path $DestinationRoot -ChildPath $NewName
if (-not (Test-Path -LiteralPath $destVmRoot)) {
    New-Item -Path $destVmRoot -ItemType Directory -Force | Out-Null
}

$safeSrcName = $SourceVmName -replace '[\\/:*?\"<>|]', '_'
$exportRoot = Join-Path -Path $TempFolder -ChildPath ("{0}_{1}" -f $safeSrcName, (Get-Date).ToString('yyyyMMddHHmmss'))
if (Test-Path -LiteralPath $exportRoot) {
    Remove-Item -LiteralPath $exportRoot -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $exportRoot -ItemType Directory -Force | Out-Null

$importedVm = $null
$sourceRenamed = $false
$tempSourceName = $null
try {
    Export-VM -VM $src -Path $exportRoot -ErrorAction Stop

    $exportVmRoot = Join-Path -Path $exportRoot -ChildPath $SourceVmName
    if (-not (Test-Path -LiteralPath $exportVmRoot)) {
        $exportChildren = Get-ChildItem -Path $exportRoot -Directory -ErrorAction SilentlyContinue
        if ($exportChildren -and $exportChildren.Count -eq 1) {
            $exportVmRoot = $exportChildren[0].FullName
        }
    }

    if (-not (Test-Path -LiteralPath $exportVmRoot)) {
        throw "Unable to locate exported VM folder under '$exportRoot'."
    }

    $tempSourceName = "{0}_hvclone_{1}" -f $SourceVmName, (Get-Date -Format 'yyyyMMddHHmmss')
    while (Get-VM -Name $tempSourceName -ErrorAction SilentlyContinue) {
        $tempSourceName = "{0}_hvclone_{1}" -f $SourceVmName, (Get-Date -Format 'yyyyMMddHHmmssffff')
    }

    try {
        Rename-VM -VM $src -NewName $tempSourceName -ErrorAction Stop
        $sourceRenamed = $true
    } catch {
        throw "Failed to temporarily rename source VM '$SourceVmName' to '$tempSourceName'. $_"
    }

    $vmcxPath = $null
    try {
        $vmcx = Get-ChildItem -Path $exportVmRoot -Recurse -Filter *.vmcx -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($vmcx) {
            $vmcxPath = $vmcx.FullName
        }
    } catch {}

    $importPath = if ($vmcxPath) { $vmcxPath } else { $exportVmRoot }

    $importedVm = Import-VM -Path $importPath -Copy -GenerateNewId -ErrorAction Stop

    if ($importedVm -and -not [string]::IsNullOrWhiteSpace($DestinationRoot)) {
        Move-VMStorage -VM $importedVm -DestinationStoragePath $destVmRoot -ErrorAction Stop
    }

    if ($importedVm) {
        Rename-VM -VM $importedVm -NewName $NewName -ErrorAction Stop
    }

    if ($importedVm) {
        $importedVm | Get-VM
    }
} finally {
    if ($sourceRenamed -and $tempSourceName) {
        try {
            Rename-VM -Name $tempSourceName -NewName $SourceVmName -ErrorAction Stop
        } catch {
            Write-Warning "Failed to restore source VM name '$SourceVmName' from '$tempSourceName'. $_"
        }
    }
    try {
        if (Test-Path -LiteralPath $exportRoot) {
            Remove-Item -LiteralPath $exportRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}
