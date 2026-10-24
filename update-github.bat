@echo off
setlocal
cd /d "%~dp0"

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo This folder is not a Git repository.
    pause
    exit /b 1
)

git diff --cached --quiet
if errorlevel 1 (
    echo There are already staged changes. Commit or unstage them first, then run this again.
    pause
    exit /b 1
)

git lfs install --local
if errorlevel 1 goto failed

git lfs track "*.ipa"
if errorlevel 1 goto failed

set "IPA=iOS/CS2M.ipa"
set /p "IPA=IPA path [%IPA%]: "
if not exist "%IPA%" (
    echo File not found: %IPA%
    pause
    exit /b 1
)

git add .gitattributes -- "%IPA%"
if errorlevel 1 goto failed

git diff --cached --quiet
if errorlevel 1 goto commit_changes
echo No new IPA changes to commit.
goto push_changes

:commit_changes
set "MESSAGE=Update IPA"
set /p "MESSAGE=Commit message [%MESSAGE%]: "
if not defined MESSAGE set "MESSAGE=Update IPA"
git commit -m "%MESSAGE%"
if errorlevel 1 goto failed

:push_changes
git push origin main
if errorlevel 1 goto failed
echo.
echo GitHub is up to date.
pause
exit /b 0

:failed
echo.
echo Update failed. Read the Git message above and fix the issue before trying again.
pause
exit /b 1
