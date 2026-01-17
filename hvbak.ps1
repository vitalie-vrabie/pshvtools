<#
.SYNOPSIS
    Hyper-V virtual machines backup.
.DESCRIPTION
    Hyper-V virtual machines backup.
    Performs VM export or online backup, depending on the OS type and integration services state.
    If guest OS is Windows and Backup integration service is available, it will perform an online backup.
    Otherwise it will export the VM. In this case, the VM will be paused for the duration of the export.
    Before performing the backup, it will delete previous backup files.
    It will not delete the backup folder, so that it can be used for other purposes (e.g. storing other files).
    The backup folder is named after the VM name.
    The backup files are named after the VM name and the date of the backup.
    The backup is performed on all VMs on the host, unless a list of VMs is provided.
    The backup is performed in the specified folder.
    The script can be run from a remote machine, but the user must have administrative privileges on the Hyper-V host.
.PARAMETER Path
    The path to the backup folder.
.PARAMETER ComputerName
    The name of the Hyper-V host. Default is localhost.
.PARAMETER VMName
    The name of the VM to backup. If not specified, all VMs will be backed up.
.EXAMPLE
    hvbak.ps1 -Path C:\Backup
    This will backup all VMs on the local host to C:\Backup.
.EXAMPLE
    hvbak.ps1 -Path C:\Backup -VMName MyVM
    This will backup MyVM on the local host to C:\Backup.
.EXAMPLE
    hvbak.ps1 -Path \\backupsrv\Hyper-V -ComputerName MyHyperVHost
    This will backup all VMs on MyHyperVHost to \\backupsrv\Hyper-V.
#>
param
(
    [string]$Path,
    [string]$ComputerName = $env:COMPUTERNAME,
    [string[]]$VMName
)

# get vms
if ($VMName)
{
    $vms = Get-VM -ComputerName $ComputerName | where {$VMName -contains $_.Name}
}
else
{
    $vms = Get-VM -ComputerName $ComputerName
}

# per vm processing
foreach ($vm in $vms)
{
    # backup path
    $bpath = Join-Path $Path $vm.Name
    if (!(Test-Path $bpath))
    {
        mkdir $bpath
    }

    # get os type
    $ostype = $vm.Notes
    if (!$ostype)
    {
        $ostype = 'Windows'
    }

    # get integration services state
    $backup_is = $vm | Get-VMIntegrationService | where {$_.Name -eq 'Backup (volume snapshot)'}

    # delete previous backup files
    $files = Get-ChildItem $bpath
    foreach ($f in $files)
    {
        if ($f.Name -like '*.exp' -or $f.Name -like '*.vhdx' -or $f.Name -like '*.avhdx' -or $f.Name -like '*.xml' -or $f.Name -like '*.bin' -or $f.Name -like '*.vsv')
        {
            del $f.FullName
        }
    }

    # online backup
    if ($ostype -like '*windows*' -and $backup_is.Enabled)
    {
        Checkpoint-VM -VM $vm -SnapshotName 'hvbaksnap'
        $snap = Get-VMSnapshot -VM $vm -Name 'hvbaksnap'
        $vhdpaths = $snap.HardDrives.path
        foreach ($vhd in $vhdpaths)
        {
            $vhdfile = (Get-Item $vhd)
            $dstf = join-path $bpath ($vhdfile.Name)
            cp $vhdfile.FullName $dstf -Force
            while ((get-item $dstf).length -lt (get-item $vhdfile.fullname).length)
            {
                start-sleep -Seconds 1
            }
        }
        $snap | Remove-VMSnapshot

        # copy vm config files
        $files = Get-ChildItem $vm.ConfigurationLocation -include *.xml,*.bin,*.vsv
        foreach ($f in $files)
        {
            $dstf = join-path $bpath ($f.Name)
            cp $f.FullName $dstf -Force
        }
    }

    #cleanup empty vm folder
    if ((gci $bpath).count -eq 0)
    {
        del $bpath
    }

    # export vm
    if ($vm.State -eq 'Running')
    {
        $vm | Export-VM -Path ($bpath + '\' + $vm.Name + '.exp')
    }
    else
    {
        # start vm if it is not running
        Start-VM -VM $vm
        $vm | Export-VM -Path ($bpath + '\' + $vm.Name + '.exp')
        Stop-VM -VM $vm
    }
}
