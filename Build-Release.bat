@echo off
REM Build-Release.bat
REM Builds PSHVTools release package using MSBuild

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   PSHVTools Release Builder
echo ========================================
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Check for MSBuild
echo Checking for MSBuild...

set "MSBUILD_PATH="

REM Try to find MSBuild via vswhere (Visual Studio 2017+)
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
        set "MSBUILD_PATH=%%i"
        goto :msbuild_found
    )
)

REM Try common MSBuild locations
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    goto :msbuild_found
)
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    goto :msbuild_found
)
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    goto :msbuild_found
)

REM Try .NET SDK MSBuild
where dotnet >nul 2>&1
if !errorlevel! equ 0 (
    set "MSBUILD_PATH=dotnet msbuild"
    goto :msbuild_found
)

REM MSBuild not found
echo.
echo [ERROR] MSBuild not found!
echo.
echo Please install one of the following:
echo - Visual Studio 2022 (any edition)
echo - .NET SDK 6.0 or later
echo.
echo Or install .NET SDK: https://dotnet.microsoft.com/download
exit /b 1

:msbuild_found
echo   [OK] Found MSBuild: !MSBUILD_PATH!
echo.

REM Clean previous builds
if exist "%SCRIPT_DIR%\release" (
    echo Cleaning previous release...
    rd /s /q "%SCRIPT_DIR%\release"
    echo   [OK] Cleaned
    echo.
)

REM Build with MSBuild
echo Building release package...
echo.

"!MSBUILD_PATH!" "%SCRIPT_DIR%\PSHVTools.csproj" /t:CreateZipArchive /p:Configuration=Release /v:minimal

if !errorlevel! neq 0 (
    echo.
    echo [ERROR] Build failed with exit code: !errorlevel!
    exit /b !errorlevel!
)

echo.
echo ========================================
echo   Build Successful!
echo ========================================
echo.

REM Display output
if exist "%SCRIPT_DIR%\release\PSHVTools-v1.0.0.zip" (
    for %%A in ("%SCRIPT_DIR%\release\PSHVTools-v1.0.0.zip") do set "FILE_SIZE=%%~zA"
    set /a "FILE_SIZE_KB=!FILE_SIZE! / 1024"
    echo Release package:
    echo   File: release\PSHVTools-v1.0.0.zip
    echo   Size: !FILE_SIZE_KB! KB
    echo.
    echo Contents:
    dir /b "%SCRIPT_DIR%\release\PSHVTools-v1.0.0\" 2>nul
)

echo.
echo ========================================
echo   Distribution Instructions
echo ========================================
echo.
echo 1. Extract the ZIP file
echo 2. Run as Administrator:
echo    .\Install-PSHVTools.ps1
echo.
echo Or distribute the ZIP file for users to:
echo - Extract
echo - Run Install-PSHVTools.ps1 as Administrator
echo.

exit /b 0
