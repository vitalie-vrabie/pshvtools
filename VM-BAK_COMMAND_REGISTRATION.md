# vm-bak Command Registration Summary

## ? Changes Completed

### 1. Module Files Updated

**vmbak.psm1:**
- Added `New-Alias -Name vm-bak -Value Invoke-VMBackup -Force`
- Updated `Export-ModuleMember` to include both aliases: `vmbak, vm-bak`
- Added example using `vm-bak` in function documentation

**vmbak.psd1:**
- Updated `AliasesToExport` to include both: `@('vmbak', 'vm-bak')`
- Updated `ProjectUri` to correct GitHub URL
- Updated `ReleaseNotes` to mention both commands

### 2. Documentation Updated

**README.md:**
- Added both command names at the top
- Updated all examples to show both `vmbak` and `vm-bak` usage
- Updated "Getting Started" section
- Added both aliases to "Highlights" section

**QUICKSTART.md:**
- Added "Available Commands" section explaining both aliases
- Updated all examples to show both commands
- Removed references to manual install scripts
- Focused on MSI installer experience
- Added troubleshooting for both commands

### 3. MSI Installer Rebuilt

**New Build:**
- ? MSI file rebuilt with updated module files
- ? Both aliases now included in the installer
- ? Size: 304 KB
- ? File: `dist\PSVMTools-Setup-1.0.0.msi`

## ?? How It Works

After installing the MSI, users can use either command:

```powershell
# Original command (still works)
vmbak -NamePattern "*"

# New hyphenated alias (also works)
vm-bak -NamePattern "*"
```

Both commands execute the same `Invoke-VMBackup` function with identical functionality.

## ?? What Gets Installed

When the MSI installer runs, it installs:

1. **Module files** to: `C:\Program Files\WindowsPowerShell\Modules\vmbak\`
   - vmbak.ps1
   - vmbak.psm1
   - vmbak.psd1

2. **Two command aliases** available system-wide:
   - `vmbak`
   - `vm-bak`

3. **Documentation** and **Start Menu shortcuts**

## ? User Experience

Users can verify both commands after installation:

```powershell
# Check module is available
Get-Module vmbak -ListAvailable

# Import module
Import-Module vmbak

# Verify both commands exist
Get-Command vmbak
Get-Command vm-bak

# Display help (either command)
vmbak
vm-bak

# Use either command interchangeably
vmbak -NamePattern "web-*"
vm-bak -NamePattern "db-*"
```

## ?? Technical Details

### Alias Registration
- Both aliases are created in `vmbak.psm1` using `New-Alias`
- Both are exported via `Export-ModuleMember -Alias vmbak, vm-bak`
- Module manifest lists both in `AliasesToExport`

### Command Resolution
```
User types: vm-bak
    ?
PowerShell resolves alias ? Invoke-VMBackup
    ?
Invoke-VMBackup function executes
    ?
Calls vmbak.ps1 with parameters
```

### Compatibility
- ? PowerShell 5.1+
- ? PowerShell 7+
- ? Windows PowerShell
- ? Both Windows Server and Desktop

## ?? Git Status

- ? **Committed:** a8dbcf9
- ? **Pushed:** to origin/master
- ? **Files changed:** 6 files
- ? **Ready for release:** Yes

## ?? Next Steps for Release

The updated MSI with `vm-bak` command is ready. When creating the GitHub release:

1. Upload the new `dist\PSVMTools-Setup-1.0.0.msi`
2. Mention both command names in release notes
3. Show examples using both `vmbak` and `vm-bak`

## ? Verification Checklist

- [x] `vm-bak` alias added to vmbak.psm1
- [x] `vm-bak` added to AliasesToExport in vmbak.psd1
- [x] README.md updated with both commands
- [x] QUICKSTART.md updated with both commands
- [x] MSI installer rebuilt
- [x] Changes committed to Git
- [x] Changes pushed to GitHub
- [x] Ready for release

---

**Both `vmbak` and `vm-bak` commands are now registered and ready to use!** ??
