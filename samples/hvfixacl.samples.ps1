#requires -Version 5.1

<#
.SYNOPSIS
  Sample usages for repairing VHD/VHDX permissions after restore/copy.

.DESCRIPTION
  Examples for `Repair-VhdAcl` and its aliases `hvfixacl` / `hv-fixacl`.

.NOTES
  - Run elevated on the Hyper-V host.
#>

Import-Module pshvtools

# List help and parameters
Get-Help Repair-VhdAcl -Full
Get-Help hvfixacl -Examples

# 1) Apply ACL fixes for all VMs on the host
hvfixacl

# 2) Using hyphenated alias
hv-fixacl

# 3) Using full function name
Repair-VhdAcl

# 4) Fix ACLs for all VHD/VHDX files under a folder
hvfixacl -VhdFolder "D:\RestoredVMs"

# 5) Fix ACLs using a CSV list of VHD paths
# CSV columns: Path (required), VMId (optional)
$csv = "C:\temp\vhds.csv"
"Path,VMId" | Out-File -FilePath $csv -Encoding utf8
'"D:\Hyper-V\MyVM\disk0.vhdx",""' | Add-Content -Path $csv

hvfixacl -VhdListCsv $csv

# 6) Custom log file
hv-fixacl -LogFile "C:\Logs\hvfixacl.log" -VhdFolder "D:\Hyper-V"

# 7) After restore workflow
hvfixacl -VhdFolder "D:\Restored"
Write-Host "ACL repair complete!" -ForegroundColor Green

# 8) Batch repair multiple folders
$folders = @("D:\Restore1", "D:\Restore2", "D:\Restore3")
foreach ($folder in $folders) {
    Write-Host "Fixing ACLs in $folder..." -ForegroundColor Cyan
    hvfixacl -VhdFolder $folder
}

# 9) Repair and report
Write-Host "Starting VHD ACL repair..." -ForegroundColor Green
hvfixacl
Write-Host "ACL repair completed. Check logs for details." -ForegroundColor Green
