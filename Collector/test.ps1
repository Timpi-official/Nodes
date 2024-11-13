# Inside test.ps1

# Define Python installer URL and path
$pythonInstallerUrl = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
$pythonInstallerPath = "$env:TEMP\python_installer.exe"

# Check if Python is installed
$pythonExists = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonExists) {
    Write-Host "Python is not installed. Downloading Python installer..."
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $pythonInstallerPath
    Write-Host "Installing Python in silent mode..."
    Start-Process -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    Remove-Item $pythonInstallerPath
    Write-Host "Python installation completed."
}

# Refresh session environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
