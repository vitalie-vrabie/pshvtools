# PSVMTools Installer Comparison

## Why We Switched from NSIS to WiX/MSI

### Overview

PSVMTools has transitioned from NSIS (.exe) installer to WiX Toolset-based MSI (Windows Installer) for better enterprise support and Windows integration.

---

## Comparison Table

| Feature | PowerShell Self-Extractor | WiX MSI Installer | NSIS EXE (Deprecated) |
|---------|--------------------------|-------------------|-----------------------|
| **File Extension** | .bat + .ps1 | .msi | .exe |
| **File Size** | ~100 KB | ~300 KB | ~200 KB |
| **Build Dependencies** | None | WiX Toolset | NSIS |
| **Windows Installer** | No | Yes ? | No |
| **Transactional Install** | No | Yes ? | No |
| **Rollback Support** | No | Yes ? | No |
| **Add/Remove Programs** | No | Yes ? | Yes |
| **Start Menu Integration** | No | Yes ? | Yes |
| **Group Policy Deployment** | Limited | Yes ? | Limited |
| **MSI Patch Support** | No | Yes ? | No |
| **Windows Server Core** | Yes ? | Yes ? | No |
| **Silent Install** | Yes | Yes ? | Yes |
| **Logging** | Basic | Advanced ? | Basic |
| **Enterprise Features** | Limited | Excellent ? | Basic |

---

## Why WiX/MSI?

### Advantages of MSI

1. **Industry Standard**
   - MSI is the official Windows Installer technology
   - Supported by Microsoft and all enterprise tools

2. **Transactional Installation**
   - Automatic rollback on failure
   - Ensures system consistency

3. **Enterprise Integration**
   - Full Group Policy support
   - SCCM/Intune integration
   - Active Directory deployment

4. **Advanced Features**
   - Windows Installer database
   - Repair functionality
   - Patch and upgrade management
   - Component tracking

5. **Better Logging**
   - Comprehensive installation logs
   - Diagnostic capabilities
   - Error reporting

6. **Security**
   - Digital signature support
   - Trusted installer model
   - Admin rights management

---

## Migration Path

### For End Users

No changes needed! The MSI installer works the same way:
- Double-click to install
- Follow the wizard
- Module is registered automatically

### For IT Departments

**Old Way (NSIS):**
```cmd
PSVMTools-Setup.exe /S
```

**New Way (MSI):**
```cmd
msiexec /i PSVMTools-Setup-1.0.0.msi /quiet /norestart
```

### Group Policy Deployment

MSI files can be deployed via Group Policy:
1. Share the MSI on network
2. Create GPO for software installation
3. Assign to computers or users
4. Automatic deployment on login/startup

---

## Build Requirements

### WiX Toolset Installation

**Option 1: Direct Download**
```
https://wixtoolset.org/releases/
```

**Option 2: Chocolatey**
```powershell
choco install wixtoolset
```

**Option 3: WinGet**
```powershell
winget install WiXToolset.WiX
```

### Building the MSI

```powershell
# Simple build
.\Build-WixInstaller.ps1

# Or build all installers
.\Build-All-Installers.ps1
```

---

## Installation Commands

### Interactive Installation
```powershell
# Double-click the MSI
# OR
msiexec /i PSVMTools-Setup-1.0.0.msi
```

### Silent Installation
```powershell
# Silent with no restart
msiexec /i PSVMTools-Setup-1.0.0.msi /quiet /norestart

# Silent with logging
msiexec /i PSVMTools-Setup-1.0.0.msi /quiet /norestart /l*v install.log

# Network install
msiexec /i \\server\share\PSVMTools-Setup-1.0.0.msi /quiet
```

### Uninstallation
```powershell
# Interactive
msiexec /x PSVMTools-Setup-1.0.0.msi

# Silent
msiexec /x PSVMTools-Setup-1.0.0.msi /quiet /norestart

# By product code
msiexec /x {PRODUCT-CODE-GUID} /quiet
```

---

## Enterprise Deployment Scenarios

### Scenario 1: Group Policy
1. Place MSI on network share
2. Open Group Policy Management
3. Create new GPO
4. Computer Configuration ? Software Settings ? Software Installation
5. Add PSVMTools MSI
6. Choose "Assigned" deployment
7. Done - installs on computer startup

### Scenario 2: SCCM/ConfigMgr
1. Import MSI into Software Library
2. Create Application or Package
3. Specify install command: `msiexec /i PSVMTools-Setup-1.0.0.msi /quiet /norestart`
4. Deploy to collections
5. Monitor deployment status

### Scenario 3: Intune
1. Upload MSI to Intune
2. Create Line-of-Business app
3. Configure install/uninstall commands
4. Assign to groups
5. Track installation status

### Scenario 4: PowerShell DSC
```powershell
Configuration InstallPSVMTools {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node "localhost" {
        Package PSVMTools {
            Ensure = "Present"
            Path = "\\server\share\PSVMTools-Setup-1.0.0.msi"
            Name = "PSVMTools"
            ProductId = "{Product-Code-GUID}"
        }
    }
}
```

---

## Backward Compatibility

### PowerShell Self-Extractor Still Available

For users who don't need MSI features, the PowerShell self-extracting installer remains available:
- No dependencies
- Cross-platform capable
- Simple to use
- Works everywhere

**Use Cases:**
- Quick testing
- Non-enterprise environments
- Air-gapped systems
- Personal use

---

## FAQ

### Q: Why not keep NSIS?
**A:** MSI provides better enterprise integration, transactional installation, and is the industry standard for Windows software deployment.

### Q: Can I still use the PowerShell installer?
**A:** Yes! The PowerShell self-extracting installer is still available and fully supported.

### Q: Do I need to uninstall NSIS version first?
**A:** Yes, if you previously installed with NSIS, uninstall it before installing the MSI version.

### Q: How do I deploy to 100s of computers?
**A:** Use Group Policy, SCCM, Intune, or PowerShell DSC. MSI makes enterprise deployment easy.

### Q: What if WiX build fails?
**A:** The PowerShell self-extractor is always available as a fallback. MSI is optional.

---

## Technical Details

### WiX Source File
- **File:** `PSVMTools-Installer.wxs`
- **Format:** XML-based installer definition
- **Compiler:** candle.exe (WiX compiler)
- **Linker:** light.exe (WiX linker)

### MSI Properties
- **Product Code:** Unique per version
- **Upgrade Code:** A3C5E8F1-9D4B-4A2C-B6E7-8F3D9C1A5B2E
- **Package ID:** Auto-generated
- **Manufacturer:** Vitalie Vrabie

### Installation Locations
- **Program Files:** `C:\Program Files\PSVMTools`
- **PowerShell Module:** `C:\Program Files\WindowsPowerShell\Modules\vmbak`
- **Start Menu:** `Start Menu\Programs\PSVMTools`

---

## Conclusion

The switch from NSIS to WiX/MSI provides:
- ? Better enterprise support
- ? Industry-standard installer
- ? Transactional installation
- ? Advanced deployment options
- ? Better Windows integration

The PowerShell self-extractor remains for simpler scenarios.

**Best of both worlds!** ??
