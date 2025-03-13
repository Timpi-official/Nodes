# Display introductory message
Write-Output "============================================="
Write-Output "Welcome to the Timpi Collector Installation!"
Write-Output "============================================="
Write-Output ""
Write-Output "This script will set up the latest version of the Timpi Collector on your system."
Write-Output "Timpi is dedicated to providing decentralized and high-quality data services."
Write-Output "This script ensures you are running with administrator privileges for a smooth setup."
Write-Output "For more information about Timpi, visit our official website at https://timpi.com."
Write-Output "============================================="
Write-Output ""

# Pause to ensure the user can read the introductory message
Read-Host -Prompt "Press Enter to continue with the installation..."

# Check if the script is running as admin
function Check-AdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "Requesting admin privileges..."
        Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
}

# Call the admin check function
Check-AdminPrivileges

# URLs and Paths
$sevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.exe"
$updateUrl = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"
$downloadsFolder = "$env:USERPROFILE\Downloads"
$installationPath = "C:\Program Files\Timpi Intl. LTD\TimpiCollector"
$updateDownloadPath = "$downloadsFolder\TimpiCollectorWindowsLatest.rar"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Function to download files with inline progress feedback
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    Write-Output "Starting download from $url..."
    Invoke-WebRequest -Uri $url -OutFile $outputPath
    Write-Output "`nDownload completed to $outputPath"
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

# Extract and move update files
function Extract-Update {
    Write-Output "Extracting update files to $installationPath..."

    # Create the installation directory if it doesn't exist
    if (!(Test-Path -Path $installationPath)) {
        New-Item -ItemType Directory -Path $installationPath | Out-Null
    }

    # Extract files to a temporary directory first
    $tempExtractPath = "$env:TEMP\TimpiCollectorExtract"
    if (Test-Path $tempExtractPath) {
        Remove-Item -Path $tempExtractPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempExtractPath | Out-Null

    Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$updateDownloadPath`" -o`"$tempExtractPath`" -y" -Wait

    # Move files from the inner folder if it exists
    $innerFolderPath = Join-Path $tempExtractPath "TimpiCollectorWindowsLatest"
    if (Test-Path $innerFolderPath) {
        Get-ChildItem -Path $innerFolderPath | Move-Item -Destination $installationPath -Force
    } else {
        # Move all files if there is no inner folder
        Get-ChildItem -Path $tempExtractPath | Move-Item -Destination $installationPath -Force
    }

    # Clean up temporary directory
    Remove-Item -Path $tempExtractPath -Recurse -Force

    Write-Output "Extraction and file move completed successfully."
}

# Main execution
Ensure-7ZipInstalled
Download-File -url $updateUrl -outputPath $updateDownloadPath
Extract-Update

# Cleanup downloaded files
Remove-Item -Path $updateDownloadPath -ErrorAction SilentlyContinue

# Final message
Write-Output "========================================================"
Write-Output "The Timpi Collector has been successfully installed!"
Write-Output "You can now access the Timpi Collector dashboard at:"
Write-Output "http://localhost:5001/collector"
Write-Output "========================================================"
Read-Host -Prompt "Press Enter to close this window"
