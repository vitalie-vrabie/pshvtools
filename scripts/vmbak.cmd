@echo off
setlocal

REM vmbak.cmd - force-load PSHVTools module, then run backup.
REM Usage:
REM   vmbak.cmd <NamePattern> [Destination] [TempFolder]
REM Example:
REM   vmbak.cmd vv-w11 w:\vmbak e:\vmbak.tmp

set "NAMEPAT=%~1"
if "%NAMEPAT%"=="" (
  echo Usage: %~nx0 ^<NamePattern^> [Destination] [TempFolder]
  exit /b 1
)

set "DEST=%~2"
if "%DEST%"=="" set "DEST=%USERPROFILE%\hvbak-archives"

set "TMP=%~3"
if "%TMP%"=="" set "TMP=%TEMP%\hvbak"

powershell -NoProfile -ExecutionPolicy Bypass -Command "^& { $ErrorActionPreference='Stop'; $modulePath = Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules\pshvtools\pshvtools.psd1'; if (-not (Test-Path -LiteralPath $modulePath)) { throw ('PSHVTools not installed at: {0}' -f $modulePath) }; Import-Module $modulePath -Force; Invoke-VMBackup -NamePattern '%NAMEPAT%' -Destination '%DEST%' -TempFolder '%TMP%' }"

endlocal
