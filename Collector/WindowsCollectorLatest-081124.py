import os
import sys
import subprocess
import shutil
import requests

# URL for downloading the Python installer
python_installer_url = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"

# Function to download files with progress feedback
def download_file(url, output_path):
    print(f"Starting download from {url}...")
    try:
        with requests.get(url, stream=True) as response:
            response.raise_for_status()
            total_size = int(response.headers.get('content-length', 0))
            downloaded_size = 0
            with open(output_path, 'wb') as file:
                for chunk in response.iter_content(chunk_size=1024):
                    if chunk:
                        file.write(chunk)
                        downloaded_size += len(chunk)
                        percent_complete = int(100 * downloaded_size / total_size) if total_size else 0
                        print(f"\rDownload progress: {percent_complete}%", end="")
            print(f"\nFile downloaded to {output_path}")
    except Exception as e:
        print(f"Download failed: {e}")
        sys.exit(1)

# Check if Python is installed; if not, download and install it
def ensure_python_installed():
    if shutil.which("python"):
        print("Python is already installed.")
        return True
    
    print("Python not found. Downloading and installing Python...")
    python_installer_path = os.path.join(os.environ["TEMP"], "python_installer.exe")
    download_file(python_installer_url, python_installer_path)
    try:
        subprocess.run([python_installer_path, "/quiet", "InstallAllUsers=1", "PrependPath=1"], check=True)
        print("Python installation completed.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to install Python: {e}")
        sys.exit(1)
    
    # Verify Python installation
    if shutil.which("python"):
        print("Python successfully installed.")
        return True
    else:
        print("Python installation failed.")
        sys.exit(1)

# Main execution
if __name__ == "__main__":
    # Ensure Python is installed
    ensure_python_installed()

    # Continue with the rest of the script here
    # Example: Running the Timpi Collector
    subprocess.run(["python", "WindowsCollectorLatest.py"])
