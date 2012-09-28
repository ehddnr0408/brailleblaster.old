; This installer script is an attempt to create a universal installer for BrailleBlaster

!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "X64.nsh"

; Some basic information

Name "BrailleBlaster"
!define APPVERSION "2012.2"
OutFile "BrailleBlaster-${APPVERSION}-installer.exe"

InstallDir "$PROGRAMFILES\brailleblaster"
InstallDirRegKey HKLM "Software\BrailleBlaster" "installdir"

RequestExecutionLevel admin

Var StartMenuFolder

Var JVMHome
Var JVMVersion
Var JVMX64

; Interface settings
!define MUI_ABORTWARNING

; The pages to show

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\..\LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "SOFTWARE\BrailleBlaster"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!insertmacro MUI_PAGE_STARTMENU BrailleBlaster $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; The languages which are supported
!insertmacro MUI_LANGUAGE "English"

Section "BrailleBlaster" SecBBInstall
  SetOutPath "$INSTDIR"
  Call JVMDetect
  ${IfNot} "$JVMHome" == ""
    ${If} "$JVMX64" == "64"
      MessageBox MB_OK "64-bit JVM detected"
    ${Else}
      MessageBox MB_OK "32-bit JVM detected"
    ${EndIf}
  ${Else}
    MessageBox MB_OK "No JVM detected"
  ${EndIf}
  ; Store the install directory
  WriteRegStr HKLM "Software\BrailleBlaster" "installdir" $INSTDIR
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "DisplayName" "BrailleBlaster"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "DisplayVersion" "${APPVERSION}"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "Publisher" "BrailleBlaster Project"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "URLInfoAbout" "http://www.brailleblaster.org"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "NoModify" 1
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster" "NoRepair" 1

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  ;The start menu group
  !insertmacro MUI_STARTMENU_WRITE_BEGIN BrailleBlaster
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

; Set the descriptions for the sections
LangString DESC_BBInstall ${LANG_ENLISH} "BrailleBlaster Application"
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecBBInstall} $(DESC_BBInstall)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; The Uninstaller section
Section "Uninstall"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  !insertmacro MUI_STARTMENU_GETFOLDER BrailleBlaster $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BrailleBlaster"
  DeleteRegKey HKLM "Software\BrailleBlaster"
SectionEnd

function JVMDetect
  ;Var /GLOBAL JVMVersion
  StrCpy $JVMVersion ""
  ;Var /GLOBAL JVMHome
  StrCpy $JVMHome ""
  ;Var /GLOBAL JVMX64
  StrCpy $JVMX64 ""
  ; If running on X64 then the user may have either 64-bit or 32-bit JVM installed
  ${If} ${RunningX64}
    SetRegView 64
    ReadRegStr $JVMVersion HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
    ReadRegSTr $JVMHome HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$JVMVersion" "JavaHome"
    ; Better check the javaw.exe actually exists here
    ${IfNot} $JVMHome == ""
      IfFileExists "$JVMHome\bin\javaw.exe" +2 0
        StrCpy $JVMHome ""
    ${EndIF}
    ; Still valid to run if the user has the JDK
    ${If} $JVMHome == ""
      ReadRegStr $JVMVersion HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
      ReadRegStr $JVMHome HKLM "SOFTWARE\Java Development Kit\$JVMVersion" "JavaHome"
      ; Check that the JDK actually exists
      ${IfNot} $JVMHome == ""
        IfFileExists "$JVMHome\bin\javaw.exe" +2 0
          StrCpy $JVMHome ""
      ${EndIf}
    ${EndIf}
    ; If a JVM has been detected by now then we better say its an X64 JVM
    ${IfNot} $JVMHome == ""
      StrCpy $JVMX64 "64"
    ${EndIf}
    SetRegView 32
  ${EndIf}
  ; Only check for a 32 bit JVM if none has been found yet
  ; This should always be the case for 32-bit systems
  ${If} $JVMHome == ""
    ReadRegStr $JVMVersion HKLM 'SOFTWARE\JavaSoft\Java Runtime Environment' "CurrentVersion"
    ReadRegStr $JVMHome HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$JVMVersion" "JavaHome"
    ${IfNot} $JVMHome == ""
      IfFileExists "$JVMHome\bin\javaw.exe" +2 0
        StrCpy $JVMHome ""
    ${EndIf}
    ; Still valid to run if the user has the JDK
    ${If} $JVMHome == ""
      ReadRegStr $JVMVersion HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
      ReadRegStr $JVMHome HKLM "SOFTWARE\Java Development Kit\$JVMVersion" "JavaHome"
      ${IfNot} $JVMHome == ""
        IfFileExists "$JVMHome\bin\javaw.exe" +2 0
          StrCpy $JVMHome ""
      ${EndIf}
    ${EndIf}
  ${EndIf}
FunctionEnd