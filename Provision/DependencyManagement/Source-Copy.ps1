param (
    $SourceDir,
    $DestSourceDir
)

# Source
if (-not (Test-Path $SourceDir)) {
    Write-Host "$SourceDir not found! Skipping copy"
    exit
}

if (Test-Path $DestSourceDir) {
    Write-Host "Source already exists on VM! Skipping copy"
    exit
}

Copy-Item -Path $SourceDir -Destination $DestSourceDir -Recurse -Force
