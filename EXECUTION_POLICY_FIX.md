# PowerShell Execution Policy Fix

## Issue

After installing the hvbak module, running `hvbak` command resulted in:

```
hvbak : The 'hvbak' command was found in the module 'hvbak', but the module could not be loaded.
For more information, run 'Import-Module hvbak'.
```

The underlying error was:
```
File hvbak.psm1 cannot be loaded because running scripts is disabled on this system.
```

## Root Cause

The PowerShell **Execution Policy** was too restrictive (all scopes were `Undefined`), which defaults to blocking unsigned scripts.

## Solution

Set the execution policy to `RemoteSigned` for the current user:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

## Verification

After applying the fix:

```powershell
# Import the module
Import-Module hvbak -Force

# Verify commands are available
Get-Command -Module hvbak

# Test the command
hvbak
```

**Result:** ? Module loads successfully and displays help information.

## Execution Policy Levels

| Policy | Description |
|--------|-------------|
| **RemoteSigned** | Local scripts run without signature. Downloaded scripts must be signed. (Recommended) |
| **AllSigned** | All scripts must be signed by a trusted publisher |
| **Unrestricted** | All scripts run, but downloaded scripts prompt for confirmation |
| **Restricted** | No scripts allowed to run (default Windows setting) |
| **Bypass** | Nothing is blocked, no warnings or prompts |

## Current Settings

```powershell
Get-ExecutionPolicy -List
```

```
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser    RemoteSigned  ?
 LocalMachine       Undefined
```

## For Users Installing via GUI Installer

The GUI installer (`PSHVTools-Setup-1.0.0.exe`) installs the module, but users may need to set the execution policy if they haven't already:

**Recommended user instruction:**
```powershell
# Run once after installation (as regular user)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or include in installation documentation:

> **Note:** If you get an error about scripts being disabled, run this command once:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

## Automated Fix in Installer

To avoid this issue, the GUI installer could optionally set the execution policy during installation. However, this requires Administrator privileges and modifies system settings, which may not be desirable.

**Alternative:** Include clear documentation in the installer completion screen and README.

## Status

? **Fixed** - Module now loads and works correctly  
? **Execution Policy:** Set to RemoteSigned for CurrentUser  
? **Commands Available:** `hvbak` and `hv-bak` both work  

---

**The hvbak module is now fully functional!** ??
