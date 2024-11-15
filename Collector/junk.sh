# Define paths and URLs for initial setup
$setupUrl = "https://timpi.io/applications/windows/TimpiSetup.msi"
$setupDownloadPath = "$env:USERPROFILE\Downloads\TimpiSetup.msi"
$installationPath = "C:\Program Files\Timpi Intl. LTD\TimpiCollector"  # Main installation path
$sevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.exe" # URL for 7-Zip installer
$sevenZipInstallerPath = "$env:USERPROFILE\Downloads\7z2201-x64.exe"

# New update URL and paths (Latest Build)
$updateUrl = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"
$updateDownloadPath = "$env:USERPROFILE\Downloads\TimpiCollectorWindowsLatest.rar"
$updateExtractPath = "$env:USERPROFILE\Downloads\TempExtractedUpdate"

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

# Function to extract a .rar file directly into the destination path
function Extract-RarFileDirectly {
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
        & "$7zipPath" x $filePath -o"$destinationPath" -y  # Extracting everything to destination
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

    # Run the installer silently
    if (Test-Path -Path $setupDownloadPath) {
        Write-Output "Installer found: ${setupDownloadPath}"
        Write-Output "Running installer silently..."
        Start-Process -FilePath $setupDownloadPath -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
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

# Download and extract the Latest update
Write-Output "Downloading the Timpi latest update..."
Download-File -url $updateUrl -outputPath $updateDownloadPath

if (Test-Path -Path $updateDownloadPath) {
    Write-Output "File downloaded successfully."

    # Create extraction directory if it doesn't exist
    if (-not (Test-Path -Path $updateExtractPath)) {
        New-Item -ItemType Directory -Path $updateExtractPath | Out-Null
    }

    # Extract the update file into the temporary directory
    Extract-RarFileDirectly -filePath $updateDownloadPath -destinationPath $updateExtractPath

    # Check if there's a folder inside the extracted content
    $extractedItems = Get-ChildItem -Path $updateExtractPath
    if ($extractedItems.Count -eq 1 -and (Test-Path "$($extractedItems.FullName)\*")) {
        Write-Output "Folder detected inside the extracted content. Moving its contents."
        $folderPath = $extractedItems.FullName
        Move-Item -Path "$folderPath\*" -Destination $installationPath -Force
    } else {
        Write-Output "No folder detected. Moving extracted files."
        Move-Item -Path "$updateExtractPath\*" -Destination $installationPath -Force
    }

    # Log files to verify
    Write-Output "Files in the installation directory after extraction:"
    Get-ChildItem -Path $installationPath -Recurse | Write-Output

    # Clean up the update files if desired
    Write-Output "Cleaning up..."
    Remove-Item -Path $updateDownloadPath -ErrorAction SilentlyContinue
    Remove-Item -Path $updateExtractPath -Recurse -ErrorAction SilentlyContinue
    Write-Output "Cleanup completed."
} else {
    Write-Output "File download failed. ${updateDownloadPath} not found."
}

Write-Output "Script execution completed. Start TimpiManager.exe, right click timpi icon from system tray and Start collector and Start UI and then open up your browser and visit http://localhost:5001/."

# Prompt to close the windows
Read-Host -Prompt 'Press Enter to close'
