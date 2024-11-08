import os
import sys
import ctypes
import subprocess
import requests
import shutil
import time

# URLs for downloading dependencies
python_installer_url = "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
seven_zip_url = "https://www.7-zip.org/a/7z2201-x64.exe"

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

# Check if 7-Zip is installed; if not, download and install it
def ensure_seven_zip_installed():
    seven_zip_path = r"C:\Program Files\7-Zip\7z.exe"
    if os.path.exists(seven_zip_path):
        print("7-Zip is already installed.")
        return True
    print("7-Zip not found. Downloading and installing 7-Zip...")
    seven_zip_installer_path = os.path.join(os.environ["TEMP"], "7z_installer.exe")
    download_file(seven_zip_url, seven_zip_installer_path)
    try:
        subprocess.run([seven_zip_installer_path, "/S"], check=True)
        print("7-Zip installation completed.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to install 7-Zip: {e}")
        sys.exit(1)

# Introductory Message
def display_intro():
    print("\n")
    print("=============================================")
    print("Welcome to the Timpi Collector Installation!")
    print("=============================================")
    print("This script will set up the latest version of the Timpi Collector on your system.")
    print("Timpi is dedicated to providing decentralized and high-quality data services.")
    print("This script ensures you running with administrator privileges for a smooth setup.")
    print("For more information about Timpi, visit our official website at https://timpi.com.")
    print("=============================================\n")

# Check for admin privileges
def is_admin():
    return ctypes.windll.shell32.IsUserAnAdmin()

# Request admin privileges if not already running as admin
if not is_admin():
    print("Requesting admin privileges...")
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)
    sys.exit()

# Define paths and URLs
downloads_folder = os.path.join(os.environ["USERPROFILE"], "Downloads")
installation_path = r"C:\Program Files\Timpi Intl. LTD\TimpiCollector"
setup_url = "https://timpi.io/applications/windows/TimpiSetup.msi"
update_url = "https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar"
setup_download_path = os.path.join(downloads_folder, "TimpiSetup.msi")
update_download_path = os.path.join(downloads_folder, "TimpiCollectorWindowsLatest.rar")

# Function to display download progress
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
        input("Press Enter to exit...")
        sys.exit(1)

# Function to install the initial setup MSI
def install_setup():
    print("Installing the main Timpi Setup...")
    try:
        subprocess.run(
            ["msiexec", "/i", setup_download_path, "/quiet", "/norestart"],
            check=True,
            capture_output=True,
            text=True
        )
        print("Main setup installation completed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Silent installation failed: {e}")
        print(f"Output: {e.stdout}")
        print(f"Error: {e.stderr}")
        input("Press Enter to exit...")
        sys.exit(1)

# Function to extract update files and move them to installation path
def extract_update():
    print(f"Extracting update files from {update_download_path} to {installation_path}...")
    seven_zip_path = r"C:\Program Files\7-Zip\7z.exe"
    if not os.path.exists(seven_zip_path):
        print("7-Zip is required for extraction but was not found. Please install it first.")
        input("Press Enter to exit...")
        sys.exit(1)

    # Extract update files into the installation directory
    try:
        subprocess.run([seven_zip_path, "x", update_download_path, f"-o{installation_path}", "-y"], check=True)
        print("Update extraction completed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Update extraction failed: {e}")
        input("Press Enter to exit...")
        sys.exit(1)

    # Check and move files from the subfolder if it exists
    subfolder_path = os.path.join(installation_path, "TimpiCollectorWindowsLatest")
    if os.path.exists(subfolder_path) and os.path.isdir(subfolder_path):
        print(f"Moving files from {subfolder_path} to {installation_path}...")
        for item in os.listdir(subfolder_path):
            source = os.path.join(subfolder_path, item)
            destination = os.path.join(installation_path, item)
            if os.path.isdir(source):
                if os.path.exists(destination):
                    shutil.rmtree(destination)
                shutil.move(source, destination)
            else:
                shutil.move(source, destination)
        print(f"Removing subfolder {subfolder_path}...")
        shutil.rmtree(subfolder_path)
        print("Subfolder removed successfully.")

# Main execution
if __name__ == "__main__":
    display_intro()

    # Ensure dependencies
    ensure_python_installed()
    ensure_seven_zip_installed()

    # Step 1: Download and install the main setup MSI
    download_file(setup_url, setup_download_path)
    install_setup()

    # Step 2: Download and extract the latest update
    download_file(update_url, update_download_path)
    extract_update()

    # Cleanup downloaded files
    os.remove(setup_download_path)
    os.remove(update_download_path)

    print("\n========================================================")
    print("The Timpi Collector has been successfully installed!")
    print("You can now access the Timpi Collector dashboard at:")
    print("http://localhost:5001/collector")
    print("========================================================\n")

    input("Press Enter to exit...")
