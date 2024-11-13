# URLs for downloading Python and the Python script
$pythonInstallerUrl = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python_installer.exe"
$pythonScriptUrl = "https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/WindowsCollectorLatest-081124.py"
$pythonScriptPath = "$env:TEMP\WindowsCollectorLatest.py"

# Function to download files
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

# Download and execute the Python script
function Run-PythonScript {
    Write-Output "Downloading the Python script..."
    Download-File -url $pythonScriptUrl -outputPath $pythonScriptPath
    Write-Output "Running the Python script..."
    python $pythonScriptPath
}

# Main execution
Ensure-PythonInstalled
Install-RequestsModule
Run-PythonScript

Write-Output "The Python script has completed."
