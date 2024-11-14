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

# Function to download files with a custom inline progress display
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    Write-Output "Starting download from $url..."

    # Initialize the .NET WebClient for download with progress updates
    $webClient = New-Object System.Net.WebClient
    $totalDownloaded = 0
    $progress = 0

    # Track the download progress
    $webClient.DownloadProgressChanged += {
        param($sender, $e)

        # Update the custom progress bar
        $newProgress = $e.ProgressPercentage
        if ($newProgress -ne $progress) {
            $progress = $newProgress
            Write-Host -NoNewline -ForegroundColor Cyan "`rDownloading: $($progress)% Complete"
        }
    }

    # Start the download and wait for it to complete
    try {
        $webClient.DownloadFile($url, $outputPath)
        Write-Output "`nDownload completed to $outputPath"
    }
    catch {
        Write-Output "Error downloading $url: $($_)"
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

# Install the main Timpi setup
function Install-Setup {
    Write-Output "Installing the main Timpi Setup..."
    Start-Process msiexec.exe -ArgumentList "/i $setupDownloadPath /quiet /norestart" -Wait
    Write-Output "Main setup installation completed successfully."
}

# Extract update files to a temporary folder and move them to the installation path
function Extract-Update {
    Write-Output "Extracting update files from $updateDownloadPath to temporary folder..."

    # Create the temporary extraction folder if it doesn't exist
    if (!(Test-Path $tempExtractionPath)) {
        New-Item -ItemType Directory -Path $tempExtractionPath | Out-Null
    }

    # Extract the files to the temporary folder
    Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$updateDownloadPath`" -o`"$tempExtractionPath`" -y" -Wait
    Write-Output "Update extraction to temporary folder completed successfully."

    # Move extracted files from the temporary folder to the installation path
    Write-Output "Moving files from temporary folder to $installationPath..."
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
