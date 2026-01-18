; PSHVTools Inno Setup Script
; Creates a professional Windows installer with GUI wizard
; Version 1.0.11

#define MyAppName "PSHVTools"
#ifndef MyAppVersion
#define MyAppVersion "1.0.11"
#endif
#ifndef MyAppLatestStableVersion
#define MyAppLatestStableVersion "1.0.9"
#endif

#define MyAppPublisher "Vitalie Vrabie"
#define MyAppURL "https://github.com/vitalie-vrabie/pshvtools"
#define MyAppDescription "PowerShell Hyper-V Tools - VM Backup Utilities"

[Setup]
; Basic application information
AppId={{8C5E8F1D-9D4B-4A2C-B6E7-8F3D9C1A5B2E}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppComments={#MyAppDescription}
AppCopyright=Copyright (C) 2026 {#MyAppPublisher}

; Installation directories
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; **CRITICAL:** Force overwrite old installation
UsePreviousAppDir=no
; Run uninstall for old version BEFORE installing new one
DisableFinishedPage=no

; Output settings
OutputDir=..\dist
OutputBaseFilename=PSHVTools-Setup
; SetupIconFile=icon.ico (commented out - optional custom icon)
Compression=lzma2/max
SolidCompression=yes

; Installer UI settings
WizardStyle=modern
WizardSizePercent=100,100
DisableWelcomePage=no
LicenseFile=..\LICENSE.txt
InfoBeforeFile=..\QUICKSTART.md

; Privileges and compatibility
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
MinVersion=6.1sp1
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Uninstall settings
; UninstallDisplayIcon={app}\icon.ico (commented out - optional custom icon)
UninstallDisplayName={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to [name] Setup
WelcomeLabel2=This will install [name/ver] on your computer.%n%nPSHVTools provides PowerShell cmdlets for backing up Hyper-V virtual machines with checkpoint support and 7-Zip compression.%n%nIt is recommended that you close all other applications before continuing.
FinishedHeadingLabel=Completing [name] Setup
FinishedLabelNoIcons=[name] has been successfully installed.%n%nThe pshvtools PowerShell module is now available system-wide.
FinishedLabel=[name] has been successfully installed.%n%nThe pshvtools PowerShell module is now available system-wide.%n%nYou can now use the following commands:%n  Import-Module hvbak%n  Get-Help Invoke-VMBackup -Full

[CustomMessages]
english.PowerShellCheck=Checking PowerShell version...
english.HyperVCheck=Checking Hyper-V availability...
english.ModuleInstall=Installing PowerShell module...

[Files]
; Module files - install to PowerShell modules directory
Source: "..\scripts\hvbak.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\hvcompact.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\hvfixacl.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\pshvtools.psm1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\pshvtools.psd1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\fix-vhd-acl.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\restore-vmbackup.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\restore-orphaned-vms.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion
Source: "..\scripts\remove-gpu-partitions.ps1"; DestDir: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: ignoreversion

; Documentation files - install to application directory
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "..\RELEASE_NOTES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\QUICKSTART.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\CHANGELOG.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\BUILD_GUIDE.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\PROJECT_SUMMARY.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Start Menu shortcuts
Name: "{group}\{#MyAppName} Documentation"; Filename: "{app}\README.md"
Name: "{group}\Changelog"; Filename: "{app}\CHANGELOG.md"
Name: "{group}\Quick Start Guide"; Filename: "{app}\QUICKSTART.md"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Registry]
; Register installation path
Root: HKLM; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; ValueType: string; ValueName: "ModulePath"; ValueData: "{commonpf64}\WindowsPowerShell\Modules\pshvtools"; Flags: uninsdeletekey

[Code]
var
  PowerShellVersionPage: TOutputMsgMemoWizardPage;
  DevBuildConsentPage: TWizardPage;
  DevBuildConsentCheck: TNewCheckBox;
  RequirementsOK: Boolean;
  NeedsDevBuildConsent: Boolean;

function NormalizeVersionForCompare(const S: String): String;
var
  T: String;
begin
  T := Trim(S);
  if (Length(T) > 0) and ((T[1] = 'v') or (T[1] = 'V')) then
    Delete(T, 1, 1);
  Result := T;
end;

procedure RequireDevBuildConsent(const CurrentVersion, ReferenceVersion, ReferenceLabel: String);
begin
  NeedsDevBuildConsent := True;
  if DevBuildConsentPage <> nil then
  begin
    DevBuildConsentPage.Caption := 'Development build warning';
    DevBuildConsentPage.Description :=
      'This installer appears to be a development build.' + #13#10 +
      'Installer version: ' + CurrentVersion + #13#10 +
      ReferenceLabel + ': ' + ReferenceVersion + #13#10 + #13#10 +
      'This build may be unstable. You must acknowledge before continuing.';
    DevBuildConsentCheck.Checked := False;
  end;
end;

function CompareSemVer(const A, B: String): Integer;
begin
  // Simple comparison - just handle the major version numbers
  if A = B then Result := 0
  else if A > B then Result := 1
  else Result := -1;
end;

procedure WarnIfOutdatedInstaller();
begin
  if CompareSemVer('{#MyAppVersion}', '{#MyAppLatestStableVersion}') > 0 then
    RequireDevBuildConsent(NormalizeVersionForCompare('{#MyAppVersion}'), NormalizeVersionForCompare('{#MyAppLatestStableVersion}'), 'Latest stable release');
end;

function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
  AppPath: String;
  ModulePath: String;
begin
  Exec('taskkill.exe', '/F /IM powershell.exe /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(1000);
  AppPath := ExpandConstant('{autopf}\PSHVTools');
  if DirExists(AppPath) then
  begin
    RemoveDir(AppPath);
    Sleep(500);
  end;
  ModulePath := ExpandConstant('{commonpf64}\WindowsPowerShell\Modules\pshvtools');
  if DirExists(ModulePath) then
  begin
    RemoveDir(ModulePath);
    Sleep(500);
  end;
  Result := True;
end;

procedure InitializeWizard();
begin
  RequirementsOK := True;
  NeedsDevBuildConsent := False;
  WarnIfOutdatedInstaller();
  if NeedsDevBuildConsent then
  begin
    DevBuildConsentPage := CreateCustomPage(wpWelcome, 'Development build warning', '');
    DevBuildConsentCheck := TNewCheckBox.Create(DevBuildConsentPage);
    DevBuildConsentCheck.Parent := DevBuildConsentPage.Surface;
    DevBuildConsentCheck.Left := ScaleX(0);
    DevBuildConsentCheck.Top := ScaleY(8);
    DevBuildConsentCheck.Width := DevBuildConsentPage.SurfaceWidth;
    DevBuildConsentCheck.Caption := 'I understand and want to continue.';
  end;
  PowerShellVersionPage := CreateOutputMsgMemoPage(wpWelcome, 'Checking System Requirements', 'Please wait while Setup checks if your system meets the requirements.', 'Setup is checking for PowerShell 5.1+ and Hyper-V...', '');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  if (DevBuildConsentPage <> nil) and (PageID = DevBuildConsentPage.ID) then
    Result := not NeedsDevBuildConsent;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (DevBuildConsentPage <> nil) and (CurPageID = DevBuildConsentPage.ID) then
  begin
    if not DevBuildConsentCheck.Checked then
    begin
      MsgBox('You must check "I understand and want to continue." to proceed.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
