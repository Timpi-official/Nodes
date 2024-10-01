# Define paths and URLs for initial setup
$setupUrl = "https://timpi.io/applications/windows/TimpiSetup.msi"
$setupDownloadPath = "$env:USERPROFILE\Downloads\TimpiSetup.msi"
$installationPath = "C:\Program Files\Timpi Intl. LTD\TimpiCollector"  # Main installation path
$sevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.exe" # URL for 7-Zip installer
$sevenZipInstallerPath = "$env:USERPROFILE\Downloads\7z2201-x64.exe"

# New update URL and paths (0.9.3)
$updateUrl = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"
$updateDownloadPath = "$env:USERPROFILE\Downloads\TimpiCollectorWindowsLatest.rar"
$updateExtractPath = "$env:USERPROFILE\Downloads\TimpiCollectorWindowsLatest"

# Function to download a file from a URL
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )
    Write-Output "Downloading file from $url..."
    try {
        (New-Object System.Net.WebClient).DownloadFile($url, $outputPath)
        Write-Output "File downloaded to $outputPath."
    } catch {
        Write-Output "Failed to download file from $url. $_"
        exit
    }
}

# Function to extract a .rar file
function Extract-RarFile {
    param (
        [string]$filePath,
        [string]$destinationPath
    )
    $7zipPath = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path -Path $7zipPath)) {
        Write-Output "7-Zip not found. Installing 7-Zip..."
        Install-7Zip
    }
    Write-Output "Extracting files from $filePath to $destinationPath..."
    try {
        & "$7zipPath" x $filePath -o"$destinationPath" -y
        Write-Output "Extraction completed successfully."
    } catch {
        Write-Output "Failed to extract files from $filePath. $_"
        exit
    }
}

# Function to install 7-Zip
function Install-7Zip {
    Write-Output "Downloading 7-Zip installer..."
    Download-File -url $sevenZipUrl -outputPath $sevenZipInstallerPath

    Write-Output "Installing 7-Zip..."
    Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait -NoNewWindow

    Write-Output "7-Zip installed successfully."
}

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "The script is not running with administrative privileges. Restarting with elevated privileges..."
    Start-Process powershell -Verb runAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`"")
    exit
}

# Main execution

# Check if 7-Zip is installed and install if necessary
if (-not (Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    Install-7Zip
}

# Download the initial setup (MSI file)
Write-Output "Downloading the initial setup..."
Download-File -url $setupUrl -outputPath $setupDownloadPath

# Verify the download
if (Test-Path -Path $setupDownloadPath) {
    Write-Output "File downloaded successfully."

    # Run the installer directly
    if (Test-Path -Path $setupDownloadPath) {
        Write-Output "Installer found: ${setupDownloadPath}"
        Write-Output "Opening installer..."
        Start-Process -FilePath $setupDownloadPath -Wait
        Write-Output "Initial installation completed."
    } else {
        Write-Output "Installer not found at ${setupDownloadPath}."
    }

    # Clean up the MSI file if desired
    Write-Output "Cleaning up..."
    Remove-Item -Path $setupDownloadPath -ErrorAction SilentlyContinue
    Write-Output "Cleanup completed."
} else {
    Write-Output "File download failed. ${setupDownloadPath} not found."
}

# Download and extract the 0.9.3 update
Write-Output "Downloading the Timpi 0.9.3 update..."
Download-File -url $updateUrl -outputPath $updateDownloadPath

if (Test-Path -Path $updateDownloadPath) {
    Write-Output "File downloaded successfully."

    # Create extraction directory if it doesn't exist
    if (-not (Test-Path -Path $updateExtractPath)) {
        New-Item -ItemType Directory -Path $updateExtractPath | Out-Null
    }

    # Extract the update file
    Extract-RarFile -filePath $updateDownloadPath -destinationPath $updateExtractPath

    # Log extracted files
    Write-Output "Extracted files:"
    Get-ChildItem -Path $updateExtractPath -Recurse | Write-Output

    # Copy the extracted files over the existing installation
    Write-Output "Copying updated files to the installation directory..."
    Copy-Item -Path "$updateExtractPath\TimpiCollectorWindowsLatest\TimpiCollector.exe" -Destination "$installationPath\TimpiCollector.exe" -Force
    Copy-Item -Path "$updateExtractPath\TimpiCollectorWindowsLatest\TimpiUI.exe" -Destination "$installationPath\TimpiUI.exe" -Force
    Copy-Item -Path "$updateExtractPath\TimpiCollectorWindowsLatest\0.9.3.txt" -Destination "$installationPath\0.9.3.txt" -Force

    # Log copied files to verify
    Write-Output "Files in the installation directory after copying:"
    Get-ChildItem -Path $installationPath -Recurse | Write-Output

    # Clean up the update files if desired
    Write-Output "Cleaning up..."
    Remove-Item -Path $updateDownloadPath -ErrorAction SilentlyContinue
    Remove-Item -Path $updateExtractPath -Recurse -ErrorAction SilentlyContinue
    Write-Output "Cleanup completed."
} else {
    Write-Output "File download failed. ${updateDownloadPath} not found."
}
