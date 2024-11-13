# URLs
$pythonInstallerUrl = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python_installer.exe"
$pythonScriptUrl = "https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/WindowsCollectorLatest-081124.py"
$pythonScriptPath = "$env:TEMP\WindowsCollectorLatest.py"

# Download function
function Download-File {
    param ($url, $outputPath)
    Write-Output "Downloading from $url..."
    Invoke-WebRequest -Uri $url -OutFile $outputPath
    Write-Output "File downloaded to $outputPath"
}

# Ensure Python is installed
function Ensure-PythonInstalled {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Output "Python is already installed."
    } else {
        Write-Output "Python not found. Downloading and installing Python..."
        Download-File -url $pythonInstallerUrl -outputPath $pythonInstallerPath
        Start-Process -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item $pythonInstallerPath -ErrorAction SilentlyContinue
        Write-Output "Python installation completed."
        
        # Refresh environment variables so Python is recognized immediately
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    }
}

# Install requests module if it is not installed
function Install-RequestsModule {
    # Check for Python executable path
    $pythonPath = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonPath) {
        # Check the common installation path as a fallback
        $pythonPath = "C:\Program Files\Python310\python.exe"
    }
    
    try {
        & $pythonPath -m pip show requests | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Requests module is already installed."
        } else {
            Write-Output "Installing requests module..."
            & $pythonPath -m pip install requests
            Write-Output "Requests module installed successfully."
        }
    } catch {
        Write-Output "Failed to install requests module. Exiting..."
        exit 1
    }
}

# Run the main Python script
function Run-PythonScript {
    Download-File -url $pythonScriptUrl -outputPath $pythonScriptPath

    # Run the Python script with the detected or fallback path
    $pythonPath = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonPath) {
        $pythonPath = "C:\Program Files\Python310\python.exe"
    }

    Write-Output "Running the Python script..."
    & $pythonPath $pythonScriptPath
}

# Main execution
Ensure-PythonInstalled
Install-RequestsModule
Run-PythonScript

Write-Output "Python script execution completed."
