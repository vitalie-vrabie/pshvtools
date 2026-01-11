@echo off
setlocal

REM Usage:
REM   vmbak.cmd <NamePattern> [Destination] [TempFolder]

set "NAMEPAT=%~1"
if "%NAMEPAT%"=="" (
  echo Usage: %~nx0 ^<NamePattern^> [Destination] [TempFolder]
  exit /b 1
)

set "DEST=%~2"
if "%DEST%"=="" set "DEST=w:\vmbak"

set "TMP=%~3"
if "%TMP%"=="" set "TMP=e:\vmbak.tmp"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $ErrorActionPreference='Stop'; $modulePath = Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules\pshvtools\pshvtools.psd1'; if (-not (Test-Path -LiteralPath $modulePath)) { throw ('PSHVTools not installed at: {0}' -f $modulePath) }; Import-Module $modulePath -Force; Invoke-VMBackup -NamePattern '%NAMEPAT%' -Destination '%DEST%' -TempFolder '%TMP%' }"

endlocal