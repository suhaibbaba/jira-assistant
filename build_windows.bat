@echo off
REM ============================================================
REM   Build Triage as a real Windows app (.exe) and an
REM   installer (.msix). Run this ONCE on Windows. After that
REM   the app installs like any other - no terminal, no modules.
REM ============================================================

echo ==^> 1/3  Getting dependencies...
call flutter pub get
if errorlevel 1 goto :error

echo ==^> 2/3  Building the Windows app (release)...
call flutter build windows --release
if errorlevel 1 goto :error

echo.
echo App built at: build\windows\x64\runner\Release\
echo You can already run triage.exe from that folder.
echo.

echo ==^> 3/3  Creating a double-click installer (.msix)...
call dart run msix:create
if errorlevel 1 (
  echo.
  echo The .msix step had an issue, but your app is ready:
  echo   build\windows\x64\runner\Release\triage.exe
  echo Zip that Release folder to share it.
  goto :end
)

echo.
echo Done!
echo   * App:       build\windows\x64\runner\Release\triage.exe
echo   * Installer: the .msix in build\windows\x64\runner\Release\
echo     Double-click it to install Triage like a normal app.
goto :end

:error
echo.
echo Build failed. Make sure Flutter and Visual Studio (Desktop C++)
echo are installed: run  flutter doctor  to check.

:end
pause
