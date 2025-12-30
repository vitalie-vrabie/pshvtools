# Command Rename Summary: vmbak/vm-bak ? hvbak/hv-bak

## ? Completed Successfully!

All command references have been renamed from `vmbak`/`vm-bak` to `hvbak`/`hv-bak` throughout the codebase.

---

## ?? What Was Changed

### 1. Command Aliases
- **Old:** `vmbak` and `vm-bak`
- **New:** `hvbak` and `hv-bak`

### 2. Rationale
- **hv** = Hyper-V (matches product name PSHVTools)
- Consistent branding: PSHVTools ? hvbak
- Shorter and more memorable
- Clearly indicates Hyper-V focus

---

## ?? Files Updated

### Core Module Files
1. **vmbak.psm1**
   - Changed `New-Alias -Name vmbak` ? `New-Alias -Name hvbak`
   - Changed `New-Alias -Name vm-bak` ? `New-Alias -Name hv-bak`
   - Updated `Export-ModuleMember -Alias vmbak, vm-bak` ? `hvbak, hv-bak`
   - Updated all examples in documentation to use `hvbak` and `hv-bak`

2. **vmbak.psd1**
   - Changed `AliasesToExport = @('vmbak', 'vm-bak')` ? `@('hvbak', 'hv-bak')`
   - Updated ReleaseNotes to mention `hvbak` and `hv-bak`

### Documentation Files
3. **README.md**
   - Updated header: Commands: `hvbak` or `hv-bak`
   - Updated all code examples
   - Updated Quick Reference section
   - Updated Getting Started section

4. **QUICKSTART.md**
   - Updated "Available Commands" section
   - Changed all command examples
   - Updated troubleshooting section

5. **RELEASE_NOTES_v1.0.0.md**
   - Updated Quick Start examples
   - Changed all command references

6. **VM-BAK_COMMAND_REGISTRATION.md**
   - Renamed to reflect new command names
   - Updated all technical details
   - Updated examples throughout

### Build Output
7. **MSI Installer**
   - Rebuilt with new command aliases
   - File: `dist\PSHVTools-Setup-1.0.0.msi`
   - Size: 304 KB

---

## ?? How Users Will Use It

After installing the MSI, both commands work:

```powershell
# Main command
hvbak -NamePattern "*"

# Hyphenated alias
hv-bak -NamePattern "*"

# Display help
hvbak
hv-bak

# All examples now use new names
hvbak -NamePattern "web-*" -Destination "D:\backups"
hv-bak -NamePattern "db-*" -Destination "E:\backups"
```

---

## ?? Command Behavior

### Alias Resolution
```
User types: hvbak
    ?
PowerShell resolves alias ? Invoke-VMBackup
    ?
Invoke-VMBackup function executes
    ?
Calls vmbak.ps1 with parameters
```

### Both Aliases Work
```powershell
# These are equivalent:
hvbak -NamePattern "*"
hv-bak -NamePattern "*"
Invoke-VMBackup -NamePattern "*"
```

---

## ? Verification

### Check Module Aliases
```powershell
Import-Module vmbak
Get-Command hvbak, hv-bak
(Get-Module vmbak).ExportedAliases
```

### Check Module Manifest
```powershell
Import-PowerShellDataFile .\vmbak.psd1 | Select-Object AliasesToExport
# Should show: hvbak, hv-bak
```

---

## ?? Complete Change Log

| File | Old References | New References | Status |
|------|---------------|----------------|--------|
| vmbak.psm1 | vmbak, vm-bak | hvbak, hv-bak | ? Updated |
| vmbak.psd1 | vmbak, vm-bak | hvbak, hv-bak | ? Updated |
| README.md | vmbak, vm-bak | hvbak, hv-bak | ? Updated |
| QUICKSTART.md | vmbak, vm-bak | hvbak, hv-bak | ? Updated |
| RELEASE_NOTES_v1.0.0.md | vmbak, vm-bak | hvbak, hv-bak | ? Updated |
| VM-BAK_COMMAND_REGISTRATION.md | vmbak, vm-bak | hvbak, hv-bak | ? Updated |
| MSI Installer | vmbak, vm-bak | hvbak, hv-bak | ? Rebuilt |

---

## ?? Git Status

- **Commit:** a2b3fa0
- **Message:** "Rename commands from vmbak/vm-bak to hvbak/hv-bak"
- **Files Changed:** 9 files
- **Pushed to:** https://github.com/vitalie-vrabie/pshvtools

---

## ?? Summary

**The command rename is complete!**

### Before:
- Commands: `vmbak` and `vm-bak`
- Product: PSVMTools

### After:
- Commands: `hvbak` and `hv-bak`
- Product: PSHVTools
- Consistent branding throughout

### Benefits:
- ? Matches product name (PSHVTools ? hvbak)
- ? Clearer Hyper-V focus
- ? Shorter and easier to remember
- ? Consistent across all documentation
- ? Both hyphenated and non-hyphenated versions available

**Ready for v1.0.0 release with new command names!** ??

---

**Date:** 2025-01-XX  
**Commit:** a2b3fa0  
**Status:** ? Complete
