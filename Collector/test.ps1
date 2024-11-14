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

# URLs for downloading dependencies
$sevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.exe"
$setupUrl = "https://timpi.io/applications/windows/TimpiSetup.msi"
$updateUrl = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"

# Paths for installation and downloads
$downloadsFolder = "$env:USERPROFILE\Downloads"
$installationPath = "C:\Program Files\Timpi Intl. LTD\TimpiCollector"
$setupDownloadPath = "$downloadsFolder\TimpiSetup.msi"
$updateDownloadPath = "$downloadsFolder\TimpiCollectorWindowsLatest.rar"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$tempExtractionPath = "$env:TEMP\TimpiCollectorExtract"

# Function to download files with inline progress feedback
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    Write-Output "Starting download from $url..."
    Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
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

# Install the main Timpi setup
function Install-Setup {
    Write-Output "Installing the main Timpi Setup..."
    Start-Process msiexec.exe -ArgumentList "/i $setupDownloadPath /quiet /norestart" -Wait
    Write-Output "Main setup installation completed successfully."
}

# Extract update files to a temporary folder and verify extraction
function Extract-Update {
    Write-Output "Extracting update files from $updateDownloadPath to temporary folder..."

    # Ensure the temporary extraction folder is created
    if (!(Test-Path $tempExtractionPath)) {
        New-Item -ItemType Directory -Path $tempExtractionPath | Out-Null
    } else {
        # Clear the folder if it already exists
        Remove-Item -Path $tempExtractionPath -Recurse -Force
        New-Item -ItemType Directory -Path $tempExtractionPath | Out-Null
    }

    # Extract the files to the temporary folder
    Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$updateDownloadPath`" -o`"$tempExtractionPath`" -y" -Wait
    Write-Output "Update extraction to temporary folder completed."

    # Verify that files were extracted
    $extractedFiles = Get-ChildItem -Path $tempExtractionPath -Recurse
    if ($extractedFiles.Count -eq 0) {
        Write-Output "No files were extracted. Please check the archive."
        Exit 1
    } else {
        Write-Output "Files successfully extracted to the temporary folder:"
        $extractedFiles | ForEach-Object { Write-Output " - $($_.FullName)" }
    }

    # Move files from temporary folder to the installation path
    Write-Output "Moving files from the temporary folder to $installationPath..."
    Get-ChildItem -Path $tempExtractionPath -Recurse | ForEach-Object {
        $destinationPath = Join-Path -Path $installationPath -ChildPath $_.Name

        # Remove existing files in the destination if they already exist
        if (Test-Path $destinationPath) {
            Write-Output "Overwriting existing file: $destinationPath"
            Remove-Item -Path $destinationPath -Force -Recurse
        }

        # Move the item to the installation path
        Move-Item -Path $_.FullName -Destination $installationPath -Force -ErrorAction Stop
        Write-Output "Moved: $($_.FullName) -> $installationPath"
    }

    # Clean up the temporary extraction folder
    Remove-Item -Path $tempExtractionPath -Recurse -Force
    Write-Output "Temporary extraction folder cleaned up."
}

# Main execution

# Ensure 7-Zip is installed
Ensure-7ZipInstalled

# Step 1: Download and install the main setup MSI
Download-File -url $setupUrl -outputPath $setupDownloadPath
Install-Setup

# Step 2: Download and extract the latest update
Download-File -url $updateUrl -outputPath $updateDownloadPath
Extract-Update

# Cleanup downloaded files
Remove-Item -Path $setupDownloadPath, $updateDownloadPath -ErrorAction SilentlyContinue

# Final message
Write-Output "========================================================"
Write-Output "The Timpi Collector has been successfully installed!"
Write-Output "You can now access the Timpi Collector dashboard at:"
Write-Output "http://localhost:5001/collector"
Write-Output "========================================================"

# Keep window open until user presses Enter
Read-Host -Prompt "Press Enter to close this window"
