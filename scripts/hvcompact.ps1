<#
.SYNOPSIS
  Compact VHDs for matching VMs using per-VM background jobs (multitasked).

.DESCRIPTION
  For each VM matching the provided NamePattern this script:
    - Optionally shuts down the VM (unless -NoAutoShutdown is supplied).
    - Runs a background job per-VM that compacts attached VHD/VHDX files with Optimize-VHD -Mode Full.
    - Restarts VMs that were stopped by the job.
    - Streams job output to the console and supports Ctrl+C cancellation.
#>

param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$NamePattern,

    [Parameter(Mandatory = $false)]
    [switch]$NoAutoShutdown
)

function Log { param($t) $ts=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); Write-Output "$ts  $t" }

# Allow passing VM name as first raw arg
if ([string]::IsNullOrWhiteSpace($NamePattern) -and $args.Count -ge 1 -and -not [string]::IsNullOrWhiteSpace([string]$args[0])) {
    $NamePattern = [string]$args[0]
}

if ([string]::IsNullOrWhiteSpace($NamePattern)) {
    Get-Help $MyInvocation.MyCommand.Path -Full
    exit 0
}

# Ensure elevated
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Error 'This script must be run as Administrator.'
    exit 1
}

Log "hvcompact starting. Pattern='{0}', NoAutoShutdown={1}" -f $NamePattern, $NoAutoShutdown.IsPresent

# Find VMs
try { $vms = Get-VM -Name $NamePattern -ErrorAction Stop } catch { Log "Get-VM failed or no VMs match: $NamePattern : $_"; exit 0 }
if (-not $vms -or $vms.Count -eq 0) { Log "No VMs found matching: $NamePattern"; exit 0 }

# Prepare cancellation sentinel
$CancelSentinel = Join-Path $env:TEMP 'hvcompact.cancel'
try { if (Test-Path $CancelSentinel) { Remove-Item -Path $CancelSentinel -Force -ErrorAction SilentlyContinue } } catch {}

$perVmJobs = @()

foreach ($vm in $vms) {
    $vmName = $vm.Name
    Log "Starting per-VM job for: $vmName"

    $job = Start-Job -ArgumentList $vmName, $NoAutoShutdown.IsPresent, $CancelSentinel -ScriptBlock {
        param($vmName, $noAutoShutdown, $cancelSentinel)

        function LocalLog { param($t) $ts=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); Write-Output "$ts  $t" }
        function IsCancelled { try { return Test-Path -LiteralPath $cancelSentinel } catch { return $false } }

        $result = [ordered]@{ VMName = $vmName; Disks = 0; Errors = 0; Restarted = $false; Success = $false; Message = '' }
        $stoppedByJob = $false

        try {
            if (IsCancelled) { throw 'Operation cancelled before start' }

            LocalLog ("Job started for {0}" -f $vmName)

            $vm = Get-VM -Name $vmName -ErrorAction Stop
            $initialState = $vm.State
            $wasRunning = ($initialState -eq 'Running')

            if (-not $noAutoShutdown) {
                if ($wasRunning) {
                    LocalLog ("Stopping VM {0} for compaction" -f $vmName)
                    try { Stop-VM -Name $vmName -Shutdown -Force -ErrorAction Stop } catch { Stop-VM -Name $vmName -TurnOff -Force -ErrorAction Stop }

                    $deadline = (Get-Date).AddSeconds(180)
                    while ((Get-Date) -lt $deadline) {
                        if (IsCancelled) { break }
                        $s = (Get-VM -Name $vmName -ErrorAction SilentlyContinue).State
                        if ($s -eq 'Off') { break }
                        Start-Sleep -Seconds 2
                    }

                    $cur = (Get-VM -Name $vmName -ErrorAction SilentlyContinue).State
                    if ($cur -ne 'Off') { throw 'VM did not stop within timeout' }
                    $stoppedByJob = $true
                    LocalLog ("VM {0} stopped" -f $vmName)
                }
            } else {
                if ($wasRunning) { throw 'VM running and NoAutoShutdown specified' }
            }

            if (IsCancelled) { throw 'Operation cancelled before compaction' }

            $disks = @(Get-VMHardDiskDrive -VMName $vmName -ErrorAction Stop)
            if ($disks.Count -eq 0) {
                LocalLog ("No VHDs attached to {0}" -f $vmName)
            } else {
                foreach ($d in $disks) {
                    if (IsCancelled) { throw 'Operation cancelled during compaction' }
                    $path = $d.Path
                    if (-not $path) { LocalLog ("Skipping disk with no path for {0}" -f $vmName); continue }
                    if (-not (Test-Path $path)) { LocalLog ("Disk path not found: {0}" -f $path); $result.Errors++; continue }

                    LocalLog ("Compacting: {0}" -f $path)
                    try {
                        Optimize-VHD -Path $path -Mode Full -ErrorAction Stop
                        $result.Disks++
                        LocalLog ("Compaction succeeded: {0}" -f $path)
                    } catch {
                        LocalLog ("Compaction failed for {0}: {1}" -f $path, $_)
                        $result.Errors++
                    }
                }
            }

            $result.Success = ($result.Errors -eq 0)
            $result.Message = 'Completed'

        } catch {
            LocalLog ("Job error for {0}: {1}" -f $vmName, $_)
            $result.Success = $false
            if (-not $result.Message) { $result.Message = $_.ToString() }
        } finally {
            if ($stoppedByJob) {
                try {
                    LocalLog ("Starting VM {0} back up" -f $vmName)
                    Start-VM -Name $vmName -ErrorAction Stop
                    $result.Restarted = $true
                    LocalLog ("VM {0} started" -f $vmName)
                } catch {
                    LocalLog ("Failed to start VM {0}: {1}" -f $vmName, $_)
                }
            }
        }

        [PSCustomObject]@{
            VMName = [string]$result.VMName
            Disks = [int]$result.Disks
            Errors = [int]$result.Errors
            Restarted = [bool]$result.Restarted
            Success = [bool]$result.Success
            Message = [string]$result.Message
        }
    }

    $perVmJobs += $job
}

if ($perVmJobs.Count -eq 0) { Log 'No per-vm jobs queued. Exiting.'; exit 0 }

# Ctrl+C handler — create sentinel and stop jobs
$global:HvCompactCancelled = $false
$script:CancelSentinelPath = $CancelSentinel
$consoleHandler = [ConsoleCancelEventHandler]{ param($sender,$e)
    try {
        $global:HvCompactCancelled = $true
        try { New-Item -Path $script:CancelSentinelPath -ItemType File -Force | Out-Null } catch {}
        Write-Output "`n$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  Ctrl+C received: initiating shutdown..."
        foreach ($j in $perVmJobs) {
            try { Stop-Job -Job $j -ErrorAction SilentlyContinue } catch {}
            Start-Sleep -Milliseconds 200
        }

        # Try to collect cleanup output
        foreach ($j in $perVmJobs) { try { $co = Receive-Job -Job $j -ErrorAction SilentlyContinue; if ($co) { $co | ForEach-Object { Write-Output $_ } } } catch {} }
    } catch { Write-Output "Error in Ctrl+C handler: $_" }
    $e.Cancel = $true
}
[Console]::add_CancelKeyPress($consoleHandler)

Log ("Monitoring {0} jobs and streaming output..." -f $perVmJobs.Count)

try {
    while ($true) {
        if ($global:HvCompactCancelled) { break }

        foreach ($j in $perVmJobs) {
            try {
                $out = Receive-Job -Job $j -ErrorAction SilentlyContinue
                if ($out) { $out | ForEach-Object { Write-Output $_ } }
            } catch {}
        }

        $running = $perVmJobs | Where-Object { $_.State -eq 'Running' }
        if (($running | Measure-Object).Count -eq 0) { break }
        Start-Sleep -Milliseconds 500
    }
} finally {
    try { [Console]::remove_CancelKeyPress($consoleHandler) } catch {}
    if ($global:HvCompactCancelled) {
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  Finalizing cancellation..."
        foreach ($j in $perVmJobs) { try { Remove-Job -Job $j -Force -ErrorAction SilentlyContinue } catch {} }
        if (Test-Path $CancelSentinel) { try { Remove-Item -Path $CancelSentinel -Force -ErrorAction SilentlyContinue } catch {} }
        Log 'Operation cancelled by user.'
        exit 130
    }
}

# Collect final results
$totalDisks = 0; $totalErrors = 0; $totalRestarted = 0
foreach ($j in $perVmJobs) {
    try { $res = Receive-Job -Job $j -Keep -ErrorAction Stop | Where-Object { $_ -is [pscustomobject] } | Select-Object -Last 1 } catch { $res = $null }

    if ($res) {
        Log ("SUMMARY: {0}: Success={1}, Disks={2}, Errors={3}, Restarted={4}" -f $res.VMName, $res.Success, $res.Disks, $res.Errors, $res.Restarted)
        $totalDisks += [int]$res.Disks
        $totalErrors += [int]$res.Errors
        if ($res.Restarted) { $totalRestarted++ }
    } else {
        Log ("SUMMARY: Job Id {0} completed. State: {1}" -f $j.Id, $j.State)
    }

    try { Remove-Job -Job $j -Force -ErrorAction SilentlyContinue } catch {}
}

Log ("All operations completed. VMs processed: {0}, Disks compacted: {1}, VMs restarted: {2}, Errors: {3}" -f $vms.Count, $totalDisks, $totalRestarted, $totalErrors)
if ($totalErrors -gt 0) { exit 1 } else { exit 0 }
