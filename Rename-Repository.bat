@echo off
REM Rename repository from psvmtools to pshvtools
REM This script updates Git remote URL after GitHub rename

echo.
echo ========================================
echo   Repository Rename: psvmtools to pshvtools
echo ========================================
echo.

REM Update Git remote URL
echo Updating Git remote URL...
git remote set-url origin https://github.com/vitalie-vrabie/pshvtools.git

REM Verify the change
echo.
echo New remote URL:
git remote get-url origin

echo.
echo ========================================
echo   Git remote updated successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Rename repository on GitHub (Settings ^> Repository name)
echo 2. Run: git fetch origin
echo 3. Run: git branch --set-upstream-to=origin/master master
echo.
