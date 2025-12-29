; PSVMTools NSIS Installer Script
; Requires NSIS 3.0 or later (https://nsis.sourceforge.io/)
;
; To build the installer:
;   1. Install NSIS from https://nsis.sourceforge.io/Download
;   2. Right-click this file and select "Compile NSIS Script"
;   OR run: makensis PSVMTools-Installer.nsi

;--------------------------------
; Includes

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

;--------------------------------
; General

; Name and file
Name "PSVMTools"
OutFile "dist\PSVMTools-Setup-1.0.0.exe"
Unicode True

; Default installation folder
InstallDir "$PROGRAMFILES\PSVMTools"

; Get installation folder from registry if available
InstallDirRegKey HKLM "Software\PSVMTools" "InstallDir"

; Request application privileges
RequestExecutionLevel admin

; Version Information
VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "PSVMTools"
VIAddVersionKey "FileDescription" "PSVMTools - PowerShell VM Backup Tools"
VIAddVersionKey "FileVersion" "1.0.0.0"
VIAddVersionKey "ProductVersion" "1.0.0.0"
VIAddVersionKey "CompanyName" "Vitalie Vrabie"
VIAddVersionKey "LegalCopyright" "Copyright (c) 2025 Vitalie Vrabie"

;--------------------------------
; Variables

Var StartMenuFolder
Var PowerShellModulePath

;--------------------------------
; Interface Settings

!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install-blue.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\nsis3-metro.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-metro.bmp"

;--------------------------------
; Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY

; Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\PSVMTools" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\docs\QUICKSTART.md"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View Quick Start Guide"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages
 
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Installer Sections

Section "PSVMTools Core" SecCore
    SetOutPath "$INSTDIR"
    
    ; Main files
    File "vmbak.ps1"
    File "vmbak.psm1"
    File "vmbak.psd1"
    
    ; Documentation
    SetOutPath "$INSTDIR\docs"
    File "README_VMBAK_MODULE.md"
    File "QUICKSTART.md"
    
    ; Store installation folder
    WriteRegStr HKLM "Software\PSVMTools" "InstallDir" $INSTDIR
    WriteRegStr HKLM "Software\PSVMTools" "Version" "1.0.0"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Add uninstall information to Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "DisplayName" "PSVMTools"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "DisplayIcon" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "Publisher" "Vitalie Vrabie"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "DisplayVersion" "1.0.0"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "HelpLink" "https://github.com/vitalie-vrabie/scripts"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools" "NoRepair" 1
    
    ; Install PowerShell module
    Call InstallPowerShellModule
    
    ; Start Menu
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
        CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
        CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Uninstall PSVMTools.lnk" "$INSTDIR\Uninstall.exe"
        CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Quick Start Guide.lnk" "$INSTDIR\docs\QUICKSTART.md"
        CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Documentation.lnk" "$INSTDIR\docs\README_VMBAK_MODULE.md"
    !insertmacro MUI_STARTMENU_WRITE_END
    
SectionEnd

;--------------------------------
; Functions

Function InstallPowerShellModule
    ; Determine PowerShell module path
    StrCpy $PowerShellModulePath "$PROGRAMFILES\WindowsPowerShell\Modules\vmbak"
    
    ; Create module directory
    CreateDirectory "$PowerShellModulePath"
    
    ; Copy module files
    CopyFiles /SILENT "$INSTDIR\vmbak.ps1" "$PowerShellModulePath"
    CopyFiles /SILENT "$INSTDIR\vmbak.psm1" "$PowerShellModulePath"
    CopyFiles /SILENT "$INSTDIR\vmbak.psd1" "$PowerShellModulePath"
    
    ; Import module (best effort)
    nsExec::ExecToLog 'powershell.exe -NoProfile -Command "Import-Module vmbak -Force"'
    
    DetailPrint "PowerShell module installed to: $PowerShellModulePath"
FunctionEnd

;--------------------------------
; Uninstaller Section

Section "Uninstall"
    ; Remove PowerShell module
    RMDir /r "$PROGRAMFILES\WindowsPowerShell\Modules\vmbak"
    
    ; Unload module if loaded
    nsExec::ExecToLog 'powershell.exe -NoProfile -Command "Remove-Module vmbak -Force -ErrorAction SilentlyContinue"'
    
    ; Remove files and directories
    Delete "$INSTDIR\vmbak.ps1"
    Delete "$INSTDIR\vmbak.psm1"
    Delete "$INSTDIR\vmbak.psd1"
    Delete "$INSTDIR\Uninstall.exe"
    
    RMDir /r "$INSTDIR\docs"
    RMDir "$INSTDIR"
    
    ; Remove Start Menu items
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
    Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall PSVMTools.lnk"
    Delete "$SMPROGRAMS\$StartMenuFolder\Quick Start Guide.lnk"
    Delete "$SMPROGRAMS\$StartMenuFolder\Documentation.lnk"
    RMDir "$SMPROGRAMS\$StartMenuFolder"
    
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PSVMTools"
    DeleteRegKey HKLM "Software\PSVMTools"
    
SectionEnd

;--------------------------------
; Section Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Core PSVMTools files and PowerShell module"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
