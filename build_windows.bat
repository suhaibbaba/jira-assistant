@echo off
REM ============================================================
REM   Build the Windows app plus a Setup.exe installer and a
REM   portable .zip into dist\. Same outputs as the GitHub
REM   Release workflow. Needs Flutter, Visual Studio (Desktop
REM   C++) and Inno Setup 6 (https://jrsoftware.org/isdl.php).
REM ============================================================
setlocal
cd /d "%~dp0"

for /f "tokens=2" %%v in ('findstr /b "version:" pubspec.yaml') do set RAWVER=%%v
for /f "tokens=1 delims=+" %%v in ("%RAWVER%") do set VERSION=%%v
set TAG=v%VERSION%
set REL=build\windows\x64\runner\Release

echo ==^> 1/4  Getting dependencies...
call flutter pub get
if errorlevel 1 goto :error

echo ==^> 2/4  Building the Windows app (release)...
call flutter build windows --release
if errorlevel 1 goto :error

echo ==^> 3/4  Bundling the VC++ runtime and zipping...
copy /y "%WINDIR%\System32\msvcp140.dll" "%REL%" >nul
copy /y "%WINDIR%\System32\vcruntime140.dll" "%REL%" >nul
copy /y "%WINDIR%\System32\vcruntime140_1.dll" "%REL%" >nul
if exist dist rmdir /s /q dist
mkdir dist
powershell -NoProfile -Command "Compress-Archive -Path '%REL%\*' -DestinationPath 'dist\Xngage-%TAG%-windows-portable.zip'"

echo ==^> 4/4  Creating Setup.exe...
set ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe
if not exist "%ISCC%" (
  echo Inno Setup 6 not found - skipping Setup.exe. Install it from
  echo https://jrsoftware.org/isdl.php  — the portable zip is ready in dist\.
  goto :end
)
"%ISCC%" /Q "/DAppVersion=%VERSION%" windows\installer\triage.iss
if errorlevel 1 goto :error

echo.
echo Done! See dist\:
dir /b dist
goto :end

:error
echo.
echo Build failed. Run  flutter doctor  to check your setup.

:end
pause
