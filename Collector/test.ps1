# Wrapper script that downloads and runs test.ps1 with retry and network checks

$maxRetries = 3
$retryCount = 0
$downloadUrl = "https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/test.ps1"
$localFilePath = "$env:TEMP\test.ps1"

# Function to check network connectivity to GitHub
function Check-NetworkConnectivity {
    Write-Output "Checking network connectivity to GitHub..."
    $pingResult = Test-Connection -ComputerName github.com -Count 1 -Quiet
    if (-not $pingResult) {
        Write-Output "Network connectivity to GitHub is unavailable. Check your internet connection."
        return $false
    } else {
        Write-Output "Network connectivity to GitHub verified."
        return $true
    }
}

# Retry loop for downloading and executing the script
do {
    if (Check-NetworkConnectivity) {
        try {
            Write-Output "Attempting to download and run the script (Attempt $($retryCount + 1) of $maxRetries)..."

            # Clear any existing file in the temp location to ensure a fresh download
            Remove-Item $localFilePath -ErrorAction SilentlyContinue

            # Download the script from GitHub
            Invoke-WebRequest -Uri $downloadUrl -OutFile $localFilePath -ErrorAction Stop

            # Execute the downloaded script
            powershell -ExecutionPolicy Bypass -File $localFilePath

            # If execution reaches this point, the script ran successfully
            $success = $true
        }
        catch {
            # Catch any errors and retry
            Write-Output "Attempt failed. Retrying..."
            $success = $false
            Start-Sleep -Seconds 2  # Wait a moment before retrying
        }
    } else {
        Write-Output "Network connectivity check failed. Retrying..."
        $success = $false
        Start-Sleep -Seconds 2
    }

    # Increment retry count
    $retryCount++

} while (-not $success -and $retryCount -lt $maxRetries)

# Final message based on success or failure
if (-not $success) {
    Write-Output "Failed to download and run the script after $maxRetries attempts."
} else {
    Write-Output "Script executed successfully."
}

# Optional: Keep the window open at the end if you want to review the output
Read-Host -Prompt "Press Enter to close this window"
