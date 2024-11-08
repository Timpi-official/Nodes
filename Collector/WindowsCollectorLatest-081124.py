import os
import sys
import ctypes
import subprocess
import requests
import shutil

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
    # Step 1: Download and install the main setup MSI
    download_file(setup_url, setup_download_path)
    install_setup()

    # Step 2: Download and extract the latest update
    download_file(update_url, update_download_path)
    extract_update()

    # Cleanup downloaded files
    os.remove(setup_download_path)
    os.remove(update_download_path)
    print("Installation and update completed successfully.")
    input("Press Enter to exit...")
