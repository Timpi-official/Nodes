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
    }
}

# Install requests module if it is not installed
function Install-RequestsModule {
    try {
        python -m pip show requests | Out-Null
        if ($?) {
            Write-Output "Requests module is already installed."
        } else {
            Write-Output "Installing requests module..."
            python -m pip install requests
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
    Write-Output "Running the Python script..."
    python $pythonScriptPath
}

# Main execution
Ensure-PythonInstalled
Install-RequestsModule
Run-PythonScript

Write-Output "Python script execution completed."
