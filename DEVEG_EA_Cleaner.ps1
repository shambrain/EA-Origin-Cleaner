# DEVEG_EA_Cleaner.ps1 - Ultimate EA App/Origin Uninstaller & Steam Fixer

# Display Title
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "         DEVEG EA Cleaner" -ForegroundColor Yellow
Write-Host " Ultimate Fixer for EA & Steam EA Games" -ForegroundColor Cyan
Write-Host "=====================================`n" -ForegroundColor Cyan

# Function to Show Progress Bar
function Show-ProgressBar {
    param (
        [string]$ActionName,
        [int]$CurrentStep,
        [int]$TotalSteps
    )
    $percent = ($CurrentStep / $TotalSteps) * 100
    Write-Progress -PercentComplete $percent -Status "$ActionName" -Activity "Step $CurrentStep of $TotalSteps"
}

# Confirm Fix Process
$choice = Read-Host "Do you want to fix EA App / Steam EA linking? (Y/N)"
if ($choice -match "^[Yy]$") {
    Write-Host "Starting EA & Steam Fix..." -ForegroundColor Cyan

    # Step 1: Stop EA and Steam Processes
    Show-ProgressBar "Stopping EA & Steam Services" 1 6
    Write-Host "Stopping EA Desktop & Steam services..." -ForegroundColor Cyan
    Stop-Process -Name "EADesktop" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "Origin" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "EABackgroundService" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "Steam" -Force -ErrorAction SilentlyContinue
    Write-Host "All EA & Steam processes stopped." -ForegroundColor Green

    # Step 2: Backup EA/Steam Registry Keys
    Show-ProgressBar "Backing up EA/Steam Registry" 2 6
    Write-Host "Backing up EA & Steam registry keys..." -ForegroundColor Cyan
    $backupFile = "$PSScriptRoot\EA_Steam_Registry_Backup.reg"
    reg export "HKCU\Software\Electronic Arts" $backupFile /y
    reg export "HKCU\Software\Valve\Steam\Apps" $backupFile /y
    Write-Host "Registry backup saved." -ForegroundColor Green

    # Step 3: Delete Corrupt Registry Keys
    Show-ProgressBar "Cleaning EA & Steam Registry" 3 6
    Write-Host "Removing corrupt EA & Steam registry entries..." -ForegroundColor Cyan
    Remove-Item -Path "HKCU:\Software\Electronic Arts" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Valve\Steam\Apps" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Registry cleanup complete." -ForegroundColor Green

    # Step 4: Delete EA Configuration Files
    Show-ProgressBar "Deleting EA Configuration" 4 6
    Write-Host "Removing EA config & cache files..." -ForegroundColor Cyan
    $ConfigPaths = @(
        "$env:LocalAppData\Electronic Arts",
        "$env:LocalAppData\Origin",
        "$env:AppData\Roaming\Electronic Arts",
        "$env:ProgramData\Electronic Arts"
    )
    foreach ($path in $ConfigPaths) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted: $path" -ForegroundColor Green
        }
    }

    # Step 5: Rebuild Steam-EA Registry Links
    Show-ProgressBar "Rebuilding Steam-EA Link" 5 6
    Write-Host "Recreating Steam-EA linking registry keys..." -ForegroundColor Cyan
    New-Item -Path "HKCU:\Software\Electronic Arts\EA Desktop" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Electronic Arts\EA Desktop" -Name "Link2EA" -Value "C:\Program Files\Electronic Arts\EA Desktop\EA Desktop\Link2EA.exe" -PropertyType String -Force | Out-Null
    Write-Host "Steam-EA linking restored." -ForegroundColor Green

    # Step 6: Restart EA Desktop & Steam
    Show-ProgressBar "Restarting EA & Steam" 6 6
    Write-Host "Restarting EA Desktop & Steam..." -ForegroundColor Cyan
    Start-Process "C:\Program Files\Electronic Arts\EA Desktop\EA Desktop\EADesktop.exe"
    Start-Process "C:\Program Files (x86)\Steam\Steam.exe"
    Write-Host "EA Desktop and Steam restarted." -ForegroundColor Green

    # Confirm Fix & Restart Suggestion
    Write-Host "`nFix Complete! Restart your PC for changes to take effect." -ForegroundColor Green
} else {
    Write-Host "Skipping EA/Steam fix." -ForegroundColor Yellow
}
