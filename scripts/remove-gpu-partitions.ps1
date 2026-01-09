#requires -Version 5.1

<#!
.SYNOPSIS
  Removes all GPU partition adapter assignments from Hyper-V VMs.

.DESCRIPTION
  For each VM matching -NamePattern, this script removes all GPU partition adapter assignments.

  It is designed to work even if the host currently has no compatible GPU available.
  To avoid querying host GPUs, it uses Remove-VMGpuPartitionAdapter directly.

.PARAMETER NamePattern
  Wildcard pattern matching VM names (e.g. "*", "lab-*", "win11*").

.PARAMETER WhatIf
  Standard PowerShell WhatIf support (inherited from SupportsShouldProcess).

.EXAMPLE
  .\remove-gpu-partitions.ps1 -NamePattern "lab-*"

.EXAMPLE
  .\remove-gpu-partitions.ps1 -NamePattern "*" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$NamePattern
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param([Parameter(Mandatory = $true)][string]$Message)
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    Write-Host "$ts  $Message"
}

try {
    Import-Module Hyper-V -ErrorAction Stop
} catch {
    throw "Failed to import Hyper-V PowerShell module. Run on a Hyper-V host. Error: $($_.Exception.Message)"
}

$vms = @()
try {
    $vms = @(Get-VM -Name $NamePattern -ErrorAction Stop)
} catch {
    # If no VMs match, Get-VM throws. Treat as a no-op.
    Write-Log "No VMs found matching pattern '$NamePattern'."
    exit 0
}

if (-not $vms -or $vms.Count -eq 0) {
    Write-Log "No VMs found matching pattern '$NamePattern'."
    exit 0
}

Write-Log ("Found {0} VM(s) matching '{1}'." -f $vms.Count, $NamePattern)

$removedCount = 0
$skippedCount = 0
$errorCount = 0

foreach ($vm in $vms) {
    try {
        $vmName = $vm.Name
        Write-Log "Processing VM: $vmName"

        # Attempt to remove *all* GPU partition adapters.
        # This does not require querying host GPUs.
        if ($PSCmdlet.ShouldProcess($vmName, 'Remove all GPU partition adapters')) {
            Remove-VMGpuPartitionAdapter -VMName $vmName -ErrorAction Stop
        }

        $removedCount++
        Write-Log "Removed GPU partition adapters (if any) from: $vmName"
    } catch {
        # When there is no GPU partition adapter attached, Hyper-V typically throws.
        # Treat that as a normal 'nothing to do' case.
        $msg = $_.Exception.Message
        if ($msg -match 'cannot find|not find|no.*GPU|GPU partition adapter|There is no') {
            $skippedCount++
            Write-Log "No GPU partition adapters to remove for: $($vm.Name)"
            continue
        }

        $errorCount++
        Write-Log "ERROR removing GPU partition adapters for $($vm.Name): $msg"
    }
}

Write-Log ("Done. Removed: {0}, No-op: {1}, Errors: {2}" -f $removedCount, $skippedCount, $errorCount)

if ($errorCount -gt 0) { exit 1 }
exit 0
