# PSHVTools GUI Launcher
# Simple GUI for PSHVTools using Windows Forms

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import PSHVTools module
Import-Module pshvtools -ErrorAction SilentlyContinue

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PSHVTools - Hyper-V VM Backup GUI"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Create controls
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(400, 30)
$label.Text = "PSHVTools - Professional Hyper-V VM Backup Tools"

$backupButton = New-Object System.Windows.Forms.Button
$backupButton.Location = New-Object System.Drawing.Point(10, 70)
$backupButton.Size = New-Object System.Drawing.Size(150, 40)
$backupButton.Text = "Backup All VMs"
$backupButton.Add_Click({
    try {
        $result = hvbak -NamePattern "*" -Verbose
        [System.Windows.Forms.MessageBox]::Show("Backup completed successfully!", "Success")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Backup failed: $($_.Exception.Message)", "Error")
    }
})

$compactButton = New-Object System.Windows.Forms.Button
$compactButton.Location = New-Object System.Drawing.Point(170, 70)
$compactButton.Size = New-Object System.Drawing.Size(150, 40)
$compactButton.Text = "Compact VHDs"
$compactButton.Add_Click({
    try {
        $result = hvcompact -NamePattern "*" -WhatIf
        [System.Windows.Forms.MessageBox]::Show("VHD compaction preview completed. Check console for details.", "Info")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("VHD compaction failed: $($_.Exception.Message)", "Error")
    }
})

$healthButton = New-Object System.Windows.Forms.Button
$healthButton.Location = New-Object System.Drawing.Point(330, 70)
$healthButton.Size = New-Object System.Drawing.Size(150, 40)
$healthButton.Text = "Health Check"
$healthButton.Add_Click({
    try {
        hvhealth
        [System.Windows.Forms.MessageBox]::Show("Health check completed. Check console for details.", "Info")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Health check failed: $($_.Exception.Message)", "Error")
    }
})

$configButton = New-Object System.Windows.Forms.Button
$configButton.Location = New-Object System.Drawing.Point(10, 130)
$configButton.Size = New-Object System.Drawing.Size(150, 40)
$configButton.Text = "Show Config"
$configButton.Add_Click({
    try {
        Show-PSHVToolsConfig
        [System.Windows.Forms.MessageBox]::Show("Configuration displayed. Check console for details.", "Info")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to show config: $($_.Exception.Message)", "Error")
    }
})

$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Location = New-Object System.Drawing.Point(170, 130)
$restoreButton.Size = New-Object System.Drawing.Size(150, 40)
$restoreButton.Text = "Restore VMs"
$restoreButton.Add_Click({
    try {
        hvrecover
        [System.Windows.Forms.MessageBox]::Show("Orphaned VM recovery completed. Check console for details.", "Info")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("VM recovery failed: $($_.Exception.Message)", "Error")
    }
})

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Location = New-Object System.Drawing.Point(10, 400)
$exitButton.Size = New-Object System.Drawing.Size(100, 40)
$exitButton.Text = "Exit"
$exitButton.Add_Click({ $form.Close() })

# Add controls to form
$form.Controls.Add($label)
$form.Controls.Add($backupButton)
$form.Controls.Add($compactButton)
$form.Controls.Add($healthButton)
$form.Controls.Add($configButton)
$form.Controls.Add($restoreButton)
$form.Controls.Add($exitButton)

# Show the form
$form.ShowDialog()