# Extract update files and move them to installation path
function Extract-Update {
    Write-Output "Extracting update files from $updateDownloadPath to $installationPath..."
    
    if (-not (Test-Path $sevenZipPath)) {
        Write-Output "7-Zip is required for extraction but was not found."
        Exit 1
    }

    # Extract files using 7-Zip directly to the installation path
    $sevenZipOutput = Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$updateDownloadPath`" -o`"$installationPath`" -y" -Wait -PassThru

    if ($sevenZipOutput.ExitCode -ne 0) {
        Write-Output "7-Zip extraction failed with exit code $($sevenZipOutput.ExitCode)."
        Exit 1
    }
    
    Write-Output "Update extraction completed successfully."

    # Check if files were extracted
    $extractedFiles = Get-ChildItem -Path $installationPath | Where-Object { $_.Name -ne "TimpiCollectorWindowsLatest" }

    if ($extractedFiles.Count -eq 0) {
        Write-Output "No files were extracted to the installation path. Please check the archive file."
        Exit 1
    } else {
        Write-Output "Files successfully extracted to $installationPath:"
        $extractedFiles | ForEach-Object { Write-Output " - $($_.Name)" }
    }

    # Move files from subfolder if it exists
    $subfolderPath = Join-Path -Path $installationPath -ChildPath "TimpiCollectorWindowsLatest"
    if (Test-Path $subfolderPath) {
        Write-Output "Moving files from $subfolderPath to $installationPath..."
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
