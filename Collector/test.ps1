# URLs for downloading dependencies
$pythonInstallerUrl = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
$sevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.exe"
$setupUrl = "https://timpi.io/applications/windows/TimpiSetup.msi"
$updateUrl = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"

# Paths for installation and downloads
$downloadsFolder = "$env:USERPROFILE\Downloads"
$installationPath = "C:\Program Files\Timpi Intl. LTD\TimpiCollector"
$setupDownloadPath = "$downloadsFolder\TimpiSetup.msi"
$updateDownloadPath = "$downloadsFolder\TimpiCollectorWindowsLatest.rar"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Function to download files with progress feedback
function Download-File {
    param ($url, $outputPath)
    Write-Output "Starting download from $url..."
    Invoke-WebRequest -Uri $url -OutFile $outputPath -ErrorAction Stop
    Write-Output "File downloaded to $outputPath"
}

# Ensure Python is installed, otherwise download and install it
function Ensure-PythonInstalled {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Output "Python is already installed."
        return
    }
    
    Write-Output "Python not found. Downloading and installing Python..."
    $pythonInstallerPath = "$env:TEMP\python_installer.exe"
    Download-File -url $pythonInstallerUrl -outputPath $pythonInstallerPath
    Start-Process -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    Remove-Item $pythonInstallerPath -ErrorAction SilentlyContinue

    # Verify installation
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Output "Python installation completed."
    } else {
        Write-Output "Python installation failed."
        Exit 1
    }
}

# Install requests module if not already installed
function Install-RequestsModule {
    try {
        python -m pip show requests -ErrorAction SilentlyContinue | Out-Null
        if ($?) {
            Write-Output "Requests module is already installed."
        } else {
            Write-Output "Installing requests module..."
            python -m pip install requests
        }
    } catch {
        Write-Output "Failed to install 'requests' module."
        Exit 1
    }
}

# Ensure 7-Zip is installed, otherwise download and install it
function Ensure-7ZipInstalled {
    if (Test-Path $sevenZipPath) {
        Write-Output "7-Zip is already installed."
        return
    }

    Write-Output "7-Zip not found. Downloading and installing 7-Zip..."
    $sevenZipInstallerPath = "$env:TEMP\7z_installer.exe"
    Download-File -url $sevenZipUrl -outputPath $sevenZipInstallerPath
    Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait
    Remove-Item $sevenZipInstallerPath -ErrorAction SilentlyContinue
    Write-Output "7-Zip installation completed."
}

# Check if the script is running as admin
function Check-AdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "Requesting admin privileges..."
        Start-Process -FilePath "powershell" -ArgumentList "-File", "$PSCommandPath" -Verb RunAs
        Exit
    }
}

# Install the main Timpi setup
function Install-Setup {
    Write-Output "Installing the main Timpi Setup..."
    Start-Process msiexec.exe -ArgumentList "/i $setupDownloadPath /quiet /norestart" -Wait
    Write-Output "Main setup installation completed successfully."
}

# Extract update files and move them to installation path
function Extract-Update {
    Write-Output "Extracting update files from $updateDownloadPath to $installationPath..."
    if (-not (Test-Path $sevenZipPath)) {
        Write-Output "7-Zip is required for extraction but was not found."
        Exit 1
    }

    Start-Process -FilePath $sevenZipPath -ArgumentList "x $updateDownloadPath -o$installationPath -y" -Wait
    Write-Output "Update extraction completed successfully."

    # Move files from subfolder if it exists
    $subfolderPath = Join-Path -Path $installationPath -ChildPath "TimpiCollectorWindowsLatest"
    if (Test-Path $subfolderPath) {
        Write-Output "Moving files from $subfolderPath to $installationPath..."
        Get-ChildItem -Path $subfolderPath -Recurse | Move-Item -Destination $installationPath
        Remove-Item -Path $subfolderPath -Recurse
        Write-Output "Subfolder removed successfully."
    }
}

# Main execution
Check-AdminPrivileges
Ensure-PythonInstalled
Install-RequestsModule
Ensure-7ZipInstalled

# Step 1: Download and install the main setup MSI
Download-File -url $setupUrl -outputPath $setupDownloadPath
Install-Setup

# Step 2: Download and extract the latest update
Download-File -url $updateUrl -outputPath $updateDownloadPath
Extract-Update

# Cleanup downloaded files
Remove-Item -Path $setupDownloadPath, $updateDownloadPath -ErrorAction SilentlyContinue

Write-Output "========================================================"
Write-Output "The Timpi Collector has been successfully installed!"
Write-Output "You can now access the Timpi Collector dashboard at:"
Write-Output "http://localhost:5001/collector"
Write-Output "========================================================"
