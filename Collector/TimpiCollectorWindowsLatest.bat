@echo off 
SETLOCAL ENABLEDELAYEDEXPANSION

:: ========= Intro =========
echo =============================================
echo       Welcome to the Timpi Collector Setup!
echo =============================================
echo.
echo This script will install or update the Timpi Collector on your system.
echo Make sure to run this script as Administrator.
echo Learn more at: https://timpi.com
echo =============================================
echo.

:: ========= Admin Check =========
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: You must run this script as Administrator.
    pause
    exit /b
)

:: ========= Variables =========
set "INSTALLATION_PATH=C:\Program Files\Timpi Intl. LTD"
set "DOWNLOADS_FOLDER=%USERPROFILE%\Downloads"
set "UPDATE_URL=https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"
set "UPDATE_DOWNLOAD_PATH=%DOWNLOADS_FOLDER%\TimpiCollectorWindowsLatest.rar"
set "TEMP_EXTRACT_PATH=%DOWNLOADS_FOLDER%\TimpiExtract"
set "SEVENZIP_URL=https://www.7-zip.org/a/7z2201-x64.exe"
set "SEVENZIP_PATH=C:\Program Files\7-Zip\7z.exe"
set "TIMPI_MANAGER_PATH=%INSTALLATION_PATH%\TimpiManager.exe"
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\TimpiManager.lnk"

:: ========= Create Install Folder =========
if not exist "%INSTALLATION_PATH%" (
    echo Creating installation directory...
    mkdir "%INSTALLATION_PATH%"
)

:: ========= Install 7-Zip if missing =========
if not exist "%SEVENZIP_PATH%" (
    echo 7-Zip not found. Downloading...
    powershell -Command "& {Invoke-WebRequest '%SEVENZIP_URL%' -OutFile '%DOWNLOADS_FOLDER%\7z_installer.exe'}"
    echo Installing 7-Zip...
    start /wait "" "%DOWNLOADS_FOLDER%\7z_installer.exe" /S
    del "%DOWNLOADS_FOLDER%\7z_installer.exe"
    echo 7-Zip installed successfully.
) else (
    echo 7-Zip is already installed.
)

:: ========= Download Timpi Collector =========
echo Downloading Latest Collector...
powershell -Command "& {Invoke-WebRequest '%UPDATE_URL%' -OutFile '%UPDATE_DOWNLOAD_PATH%'}"

:: ========= Extract Files =========
echo Extracting files...
if exist "%TEMP_EXTRACT_PATH%" rd /s /q "%TEMP_EXTRACT_PATH%"
mkdir "%TEMP_EXTRACT_PATH%"
"%SEVENZIP_PATH%" x "%UPDATE_DOWNLOAD_PATH%" -o"%TEMP_EXTRACT_PATH%" -y
del "%UPDATE_DOWNLOAD_PATH%"
echo Extraction complete.

:: ========= Move Files =========
echo Moving extracted files to install directory...
xcopy /E /Y /C /H /R "%TEMP_EXTRACT_PATH%\*" "%INSTALLATION_PATH%\" >nul
rd /s /q "%TEMP_EXTRACT_PATH%"
echo Files moved.

:: ========= Set Permissions =========
echo Setting full permissions...
icacls "%INSTALLATION_PATH%" /grant Everyone:F /T /C /Q

:: ========= Remove Old Timpi Manager Service =========
echo Removing Timpi Manager service if it exists...
sc stop "TimpiManager" >nul 2>&1
sc delete "TimpiManager" >nul 2>&1

:: ========= Create Timpi Collector Service =========
echo Installing Timpi Collector service...
sc stop "Timpi Collector" >nul 2>&1
sc delete "Timpi Collector" >nul 2>&1
sc create "Timpi Collector" binPath= "\"C:\Program Files\Timpi Intl. LTD\TimpiService.exe\"" start= auto obj= "LocalSystem"
sc failure "Timpi Collector" reset= 0 actions= restart/60000
echo Timpi Collector service created successfully.

:: ========= Start Timpi Collector Service =========
echo Starting Timpi Collector service...
net start "Timpi Collector"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not start the service. You may start it manually via services.msc.
    pause
    exit /b
)

:: ========= Create Desktop Shortcut =========
echo Creating shortcut for TimpiManager.exe on Desktop...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%TIMPI_MANAGER_PATH%'; $Shortcut.WorkingDirectory = '%INSTALLATION_PATH%'; $Shortcut.IconLocation = '%TIMPI_MANAGER_PATH%'; $Shortcut.Save()"
echo Shortcut created successfully!

:: ========= Done =========
echo =============================================
echo Timpi Collector has been successfully installed!
echo Dashboard: http://localhost:5015/collector
echo Shortcut for TimpiManager.exe has been created on your Desktop!
echo =============================================
pause
exit
