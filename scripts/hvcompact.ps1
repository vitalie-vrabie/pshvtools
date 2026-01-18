<#
.SYNOPSIS
  Compact all VHDs of VMs specified as a parameter with * wildcard in their names.

.DESCRIPTION
  For each VM matching the provided NamePattern this script:
    - Retrieves all VHD/VHDX disks attached to the VM.
    - Compacts each disk using Optimize-VHD with full reclamation mode.
    - Reports progress and status for each compaction operation.
    - Requires the VM to be stopped before compacting.

.PARAMETER NamePattern
  Wildcard pattern to match VM names (e.g., "*" for all VMs, "web-*" for VMs starting with "web-").

.EXAMPLE
  .\hvcompact.ps1 -NamePattern "*"
  Compacts all VHDs of all VMs.

.EXAMPLE
  .\hvcompact.ps1 -NamePattern "srv-*"
  Compacts all VHDs of VMs matching "srv-*".

.EXAMPLE
  .\hvcompact.ps1 "web-*"
  Positional parameter - compacts all VHDs of VMs matching "web-*".

.NOTES
  - Run elevated (Administrator) on the Hyper-V host.
  - VMs must be stopped before VHD compaction can proceed.
  - Compaction can be time-consuming depending on VHD size.
  - Compaction releases unused space from the VHD to the host storage.
  - Supports Ctrl+C cancellation.
#>

param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$NamePattern
)

# Allow passing VM name as first raw arg (e.g. from cmd files) even if caller forgets -NamePattern
if ([string]::IsNullOrWhiteSpace($NamePattern) -and $args.Count -ge 1 -and -not [string]::IsNullOrWhiteSpace([string]$args[0])) {
    $NamePattern = [string]$args[0]
}

# Display help if no NamePattern provided
if ([string]::IsNullOrWhiteSpace($NamePattern)) {
    Get-Help $PSCommandPath -Full
    exit
}

# Verify admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

try {
    # Get VMs matching the pattern
    Write-Host "Searching for VMs matching pattern: $NamePattern" -ForegroundColor Cyan
    $vms = @(Get-VM -Name $NamePattern -ErrorAction Stop)

    if ($vms.Count -eq 0) {
        Write-Host "No VMs found matching pattern: $NamePattern" -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Found $($vms.Count) VM(s) to process" -ForegroundColor Green
    Write-Host ""

    $totalDisksCompacted = 0
    $totalErrors = 0

    foreach ($vm in $vms) {
        $vmName = $vm.Name
        $vmState = $vm.State

        Write-Host "Processing VM: $vmName (State: $vmState)" -ForegroundColor Cyan

        # Check if VM is stopped
        if ($vmState -ne "Off") {
            Write-Host "  WARNING: VM is not in stopped state. Skipping compaction." -ForegroundColor Yellow
            continue
        }

        try {
            # Get all hard disk drives for this VM
            $disks = @(Get-VMHardDiskDrive -VMName $vmName -ErrorAction Stop)

            if ($disks.Count -eq 0) {
                Write-Host "  No VHDs attached to this VM" -ForegroundColor Gray
                continue
            }

            Write-Host "  Found $($disks.Count) disk(s) attached" -ForegroundColor Gray

            foreach ($disk in $disks) {
                $diskPath = $disk.Path
                $diskController = $disk.ControllerNumber
                $diskLocation = $disk.ControllerLocation

                if (-not $diskPath) {
                    Write-Host "    WARNING: Disk controller $diskController, location $diskLocation has no path. Skipping." -ForegroundColor Yellow
                    continue
                }

                if (-not (Test-Path $diskPath)) {
                    Write-Host "    WARNING: Disk path not found: $diskPath" -ForegroundColor Yellow
                    continue
                }

                Write-Host "    Compacting: $diskPath" -ForegroundColor Gray

                try {
                    # Compact the VHD using full reclamation
                    Optimize-VHD -Path $diskPath -Mode Full -ErrorAction Stop
                    Write-Host "      SUCCESS: Compaction completed" -ForegroundColor Green
                    $totalDisksCompacted++
                } catch {
                    Write-Host "      ERROR: Compaction failed - $_" -ForegroundColor Red
                    $totalErrors++
                }
            }
        } catch {
            Write-Host "  ERROR: Failed to process VM - $_" -ForegroundColor Red
            $totalErrors++
        }

        Write-Host ""
    }

    # Summary
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Compaction Summary:" -ForegroundColor Cyan
    Write-Host "  VMs processed: $($vms.Count)" -ForegroundColor Green
    Write-Host "  Disks compacted: $totalDisksCompacted" -ForegroundColor Green
    Write-Host "  Errors: $totalErrors" -ForegroundColor $(if ($totalErrors -gt 0) { "Red" } else { "Green" })
    Write-Host "========================================" -ForegroundColor Cyan

    if ($totalErrors -gt 0) {
        exit 1
    }

} catch {
    Write-Error "Fatal error: $_"
    exit 1
}
