#requires -Version 5.1

<#
.SYNOPSIS
  Sample usages for compacting VHDs with PSHVTools.

.DESCRIPTION
  Examples for `Invoke-VHDCompact` and its aliases `hvcompact` / `hv-compact`.

.NOTES
  - Run elevated (Administrator) on the Hyper-V host.
  - VMs must be in an Off (stopped) state before compacting.
  - Compaction can be time-consuming depending on VHD size.
#>

Import-Module pshvtools

# List help and parameters
Get-Help Invoke-VHDCompact -Full
Get-Help hvcompact -Examples

# 1) Compact all VHDs for all VMs
hvcompact -NamePattern "*"

# 2) Compact VHDs for a single VM
hvcompact -NamePattern "MyVM"

# 3) Compact VHDs for a set of VMs using wildcard
hv-compact -NamePattern "srv-*"

# 4) Compact using positional parameter
hvcompact "*"

# 5) Compact specific VM group
hvcompact -NamePattern "web-*"

# 6) Compact production VMs
hvcompact -NamePattern "prod-*"

# 7) Compact development VMs
hv-compact -NamePattern "dev-*"

# 8) Compact before backup (to reduce archive size)
# First compact all VMs
hvcompact -NamePattern "*"
# Then backup
hvbak -NamePattern "*"

# 9) Weekly maintenance script
Import-Module pshvtools
Write-Host "Starting weekly maintenance..." -ForegroundColor Cyan

# Backup all VMs
Write-Host "Backing up all VMs..." -ForegroundColor Green
hvbak -NamePattern "*" -KeepCount 4

# Fix VHD permissions if needed
Write-Host "Fixing VHD permissions..." -ForegroundColor Green
fix-vhd-acl

# Compact VHDs to reclaim space
Write-Host "Compacting VHDs..." -ForegroundColor Green
hvcompact -NamePattern "*"

Write-Host "Weekly maintenance complete!" -ForegroundColor Green

# 10) Compact VM groups at different times
# Morning: backup and compact production
hvbak -NamePattern "prod-*" -KeepCount 7
hvcompact -NamePattern "prod-*"

# Afternoon: compact development (non-critical)
hvcompact -NamePattern "dev-*"

# 11) Monitor compaction results
# Compact and capture results
$result = hvcompact -NamePattern "*"

# 12) Error handling in scripts
try {
    hvcompact -NamePattern "*"
    Write-Host "Compaction succeeded!" -ForegroundColor Green
} catch {
    Write-Error "Compaction failed: $_"
    exit 1
}
