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

# Function to download files with inline progress feedback
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    # Start the download and display progress
    Write-Output "Starting download from $url..."

    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head
    $totalSize = [math]::Round($response.Headers['Content-Length'] / 1MB, 2) # Total size in MB for display
    $totalBytes = $response.Headers['Content-Length'] # Total size in bytes

    $webRequest = [System.Net.HttpWebRequest]::Create($url)
    $webRequest.Method = "GET"
    $responseStream = $webRequest.GetResponse().GetResponseStream()
    $fileStream = [System.IO.File]::Create($outputPath)
    $buffer = New-Object byte[] 8192 # Buffer size (8 KB)
    $totalDownloaded = 0
    $percentComplete = 0

    while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fileStream.Write($buffer, 0, $read)
        $totalDownloaded += $read
        $newPercentComplete = [math]::Floor(($totalDownloaded / $totalBytes) * 100)

        if ($newPercentComplete -ne $percentComplete) {
            $percentComplete = $newPercentComplete
            # Print progress in the same line
            Write-Host -NoNewline -ForegroundColor Cyan "`rDownloading: $percentComplete% Complete"
        }
    }

    $fileStream.Close()
    $responseStream.Close()
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

# Updated Extract-Update function
function Extract-Update {
    Write-Output "Extracting update files from $updateDownloadPath to $installationPath..."
    if (-not (Test-Path $sevenZipPath)) {
        Write-Output "7-Zip is required for extraction but was not found."
        Exit 1
    }

    # Extract files using 7-Zip
    Start-Process -FilePath $sevenZipPath -ArgumentList "x $updateDownloadPath -o$installationPath -y" -Wait
    Write-Output "Update extraction completed successfully."

    # Move files from subfolder if it exists
    $subfolderPath = Join-Path -Path $installationPath -ChildPath "TimpiCollectorWindowsLatest"
    if (Test-Path $subfolderPath) {
        Write-Output "Moving files from $subfolderPath to $installationPath..."

        # Loop through each item in the subfolder and move it individually
        Get-ChildItem -Path $subfolderPath -Recurse | ForEach-Object {
            $destinationPath = Join-Path -Path $installationPath -ChildPath $_.Name

            # Remove existing files in the destination if they already exist
            if (Test-Path $destinationPath) {
                Write-Output "Overwriting existing file: $destinationPath"
                Remove-Item -Path $destinationPath -Force -Recurse
            }

            # Move the item to the destination path
            Move-Item -Path $_.FullName -Destination $installationPath -Force -ErrorAction Stop
            Write-Output "Moved: $($_.FullName) -> $installationPath"
        }

        # Remove the subfolder after moving the files
        Remove-Item -Path $subfolderPath -Recurse
        Write-Output "Subfolder removed successfully."
    }
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
