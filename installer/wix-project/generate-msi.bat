@ECHO OFF
SETLOCAL
ECHO ** Generating PX4 Toolchain MSI Installer

REM base directory of the source files
set BASEDIR=%~dp0..\..
SET BASEDIR=%~dp0..\Old\samplefirst\

REM WiX Toolset binaries folder
SET WIXDIR=%~dp0..\wix-binaries


PUSHD %BASEDIR%
ECHO Base driectory to create the installer for: %CD%
POPD

REM packing cygwin symbolic links into an archive
REM to preserve them for after the installation
ECHO *** Symbolic links: Backing up
call %BASEDIR%\toolchain\symlinks-backup-before-install.bat

REM create and switch to output folder
CD %~dp0
if not exist ".\build\" mkdir build
cd build

REM run WiX Toolset to create the msi installer
ECHO *** Running WiX Heat to harvest source file database
%WIXDIR%\heat.exe ^
dir %BASEDIR% ^
-out heat.wxs ^
-dr INSTALLDIR ^
-cg MainComponents ^
-gg -g1 -sreg -srd -sfrag -ke ^
-t ..\exclude.xlst

ECHO *** Running WiX Candle to compile installation scripts
%WIXDIR%\candle.exe ..\PX4.wxs ..\ui.wxs heat.wxs

ECHO *** Running WiX Light to link the installer file
%WIXDIR%\light.exe ^
-ext WixUIExtension ^
heat.wixobj PX4.wixobj ui.wixobj ^
-b %BASEDIR% ^
-loc ..\custom_ui_text.wxl ^
-out "PX4 Toolchain.msi"

REM remove the symbolic link backup archive from the source directory
ECHO *** Symbolic links: Removing Backup
call %BASEDIR%\toolchain\symlinks-remove-backup.bat

PAUSE
ENDLOCAL
