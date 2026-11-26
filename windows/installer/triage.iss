; Inno Setup script — builds a normal Windows "Setup.exe" installer for the app.
;
; Compile (CI does this automatically, see .github/workflows/release.yml):
;   iscc /DAppVersion=1.7.0 /DSourceDir=..\..\build\windows\x64\runner\Release windows\installer\triage.iss
;
; Installs per-user by default (no admin prompt), adds Start Menu + optional
; desktop shortcut, and registers an uninstaller in "Apps & features".
; Re-running a newer Setup.exe upgrades in place (same AppId).

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

; Keep in sync with AppInfo.appNameFull (lib/config/app_info.dart).
#define AppName "Xngage - Jira Assistance"
#define AppPublisher "Xngage"
#define AppExeName "triage.exe"

[Setup]
; Never change AppId — it is how upgrades/uninstall find the existing install.
AppId={{5DC4D186-9F2B-4595-B067-0F19E798AFC5}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/suhaibbaba/jira-assistant
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=Xngage-v{#AppVersion}-windows-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
