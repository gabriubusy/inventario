; Inno Setup script for the Windows build of Inventario.
; Build first: flutter build windows --release (needs Visual Studio with C++).

#define NombreApp "Inventario"
#define VersionApp "0.1.0"
#define Ejecutable "inventario.exe"
#define Compilado "..\build\windows\x64\runner\Release"

[Setup]
AppId={{7A3EE09A-3FFD-4CEE-97E0-96563E4BB347}
AppName={#NombreApp}
AppVersion={#VersionApp}
AppPublisher=Appyweb
; Per-user install: no administrator needed on the shop's computer.
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\{#NombreApp}
DefaultGroupName={#NombreApp}
DisableProgramGroupPage=yes
OutputDir=salida
OutputBaseFilename=instalar-inventario-{#VersionApp}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#Ejecutable}

[Languages]
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "escritorio"; Description: "Crear un acceso directo en el escritorio"; GroupDescription: "Accesos directos:"

[Files]
Source: "{#Compilado}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#NombreApp}"; Filename: "{app}\{#Ejecutable}"
Name: "{autodesktop}\{#NombreApp}"; Filename: "{app}\{#Ejecutable}"; Tasks: escritorio

[Run]
Filename: "{app}\{#Ejecutable}"; Description: "Abrir {#NombreApp}"; Flags: nowait postinstall skipifsilent

; The data (inventario.sqlite, imagenes/) lives in AppData and is kept on
; uninstall, so reinstalling never loses the stock.
