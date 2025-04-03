# ========================== Intro ==========================
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "           Welcome to the Timpi Collector Setup!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will install or update the Timpi Collector on your system."
Write-Host "Make sure to run this script as Administrator."
Write-Host "Learn more at: https://timpi.com"
Write-Host "=================================================="
Write-Host ""

# ========================== Admin Check ==========================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: You must run this script as Administrator." -ForegroundColor Red
    Pause
    Exit
}

# ========================== Variables ==========================
$INSTALLATION_PATH = "C:\Program Files\Timpi Intl. LTD"
$DOWNLOADS_FOLDER = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
$UPDATE_URL = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"
$UPDATE_DOWNLOAD_PATH = "$DOWNLOADS_FOLDER\TimpiCollectorWindowsLatest.rar"
$TEMP_EXTRACT_PATH = "$DOWNLOADS_FOLDER\TimpiExtract"
$SEVENZIP_URL = "https://www.7-zip.org/a/7z2201-x64.exe"
$SEVENZIP_PATH = "C:\Program Files\7-Zip\7z.exe"
$TIMPI_MANAGER_PATH = "$INSTALLATION_PATH\TimpiManager.exe"
$SHORTCUT_PATH = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "TimpiManager.lnk")

# ========================== Create Install Folder ==========================
if (!(Test-Path $INSTALLATION_PATH)) {
    Write-Host "Creating installation directory..."
    New-Item -ItemType Directory -Path $INSTALLATION_PATH -Force | Out-Null
}

# ========================== Install 7-Zip if missing ==========================
if (!(Test-Path $SEVENZIP_PATH)) {
    Write-Host "7-Zip not found. Downloading..."
    Invoke-WebRequest -Uri $SEVENZIP_URL -OutFile "$DOWNLOADS_FOLDER\7z_installer.exe"
    Write-Host "Installing 7-Zip..."
    Start-Process -FilePath "$DOWNLOADS_FOLDER\7z_installer.exe" -ArgumentList "/S" -Wait
    Remove-Item "$DOWNLOADS_FOLDER\7z_installer.exe"
    Write-Host "7-Zip installed successfully."
} else {
    Write-Host "7-Zip is already installed."
}

# ========================== Download Timpi Collector ==========================
Write-Host "Downloading Latest Collector..."
Invoke-WebRequest -Uri $UPDATE_URL -OutFile $UPDATE_DOWNLOAD_PATH

# ========================== Extract Files ==========================
Write-Host "Extracting files..."
if (Test-Path $TEMP_EXTRACT_PATH) { Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH }
New-Item -ItemType Directory -Path $TEMP_EXTRACT_PATH | Out-Null
Start-Process -FilePath $SEVENZIP_PATH -ArgumentList "x", $UPDATE_DOWNLOAD_PATH, "-o$TEMP_EXTRACT_PATH", "-y" -NoNewWindow -Wait
Remove-Item $UPDATE_DOWNLOAD_PATH
Write-Host "Extraction complete."

# ========================== Move Files ==========================
Write-Host "Moving extracted files to install directory..."
Copy-Item -Path "$TEMP_EXTRACT_PATH\*" -Destination $INSTALLATION_PATH -Recurse -Force
Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
Write-Host "Files moved."

# ========================== Set Permissions ==========================
Write-Host "Setting full permissions..."
icacls $INSTALLATION_PATH /grant Everyone:F /T /C /Q | Out-Null

# ========================== Remove Old Timpi Manager Service ==========================
Write-Host "Removing Timpi Manager service if it exists..."
Stop-Service -Name "TimpiManager" -ErrorAction SilentlyContinue
sc.exe delete "TimpiManager" > $null

# ========================== Create Timpi Collector Service ==========================
Write-Host "Installing Timpi Collector service..."
Stop-Service -Name "Timpi Collector" -ErrorAction SilentlyContinue
sc.exe delete "Timpi Collector" > $null
sc.exe create "Timpi Collector" binPath= "`"$INSTALLATION_PATH\TimpiService.exe`"" start= auto obj= "LocalSystem"
sc.exe failure "Timpi Collector" reset= 0 actions= restart/60000
Write-Host "Timpi Collector service created successfully."

# ========================== Start Timpi Collector Service ==========================
Write-Host "Starting Timpi Collector service..."
Start-Service -Name "Timpi Collector"

# ========================== Create Desktop Shortcut ==========================
Write-Host "Creating shortcut for TimpiManager.exe on Desktop..."
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($SHORTCUT_PATH)
$Shortcut.TargetPath = $TIMPI_MANAGER_PATH
$Shortcut.WorkingDirectory = $INSTALLATION_PATH
$Shortcut.IconLocation = $TIMPI_MANAGER_PATH
$Shortcut.Save()
Write-Host "Shortcut created successfully!"

# ========================== Done ==========================
Write-Host "=================================================="
Write-Host "Timpi Collector has been successfully installed!"
Write-Host "Dashboard: http://localhost:5015/collector"
Write-Host "Shortcut for TimpiManager.exe has been created on your Desktop!"
Write-Host "=================================================="
Pause
