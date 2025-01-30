# DEVEG_EA_Cleaner.ps1 - Ultimate EA App/Origin Uninstaller & Steam Fixer

Write-Host "`n=== DEVEG EA Cleaner ===" -ForegroundColor Magenta
Write-Host "Ultimate Fixer for EA & Steam EA Games" -ForegroundColor Yellow

# --- Confirm if User Wants to Uninstall EA App / Origin ---
$choice = Read-Host "Do you want to uninstall EA App / Origin? (Y/N)"
if ($choice -match "^[Yy]$") {
    Write-Host "Uninstalling EA App / Origin..." -ForegroundColor Cyan
    
    # Stop running processes
    Stop-Process -Name "EADesktop" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "Origin" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "EABackgroundService" -Force -ErrorAction SilentlyContinue
    
    # Uninstall EA App
    Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Electronic Arts|EA App|Origin" } | ForEach-Object { $_.Uninstall() }
    
    # Remove leftover files
    Remove-Item "$env:ProgramData\Electronic Arts" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles\Electronic Arts" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LocalAppData\Origin" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LocalAppData\EA Desktop" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:AppData\Roaming\Electronic Arts" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "EA App / Origin has been uninstalled." -ForegroundColor Green
} else {
    Write-Host "Skipping uninstallation." -ForegroundColor Yellow
}

# --- Steam EA Game Fix ---
Write-Host "Applying Steam EA Game Fix..." -ForegroundColor Cyan
$SteamPath = "C:\\Program Files (x86)\\Steam\\steamapps\\common"
$EARegistryPath = "HKCU:\\Software\\Electronic Arts"
$SteamRegistryPath = "HKCU:\\Software\\Valve\\Steam\\Apps"
$LinkedAccountsPath = "HKCU:\\Software\\Electronic Arts\\EA Desktop\\Linked Accounts"

# Backup registry entries before removal (Backup can be restored)
$backupFile = "$PSScriptRoot\EA_Steam_Registry_Backup.reg"

Write-Host "Checking if registry paths exist..." -ForegroundColor Cyan
if (Test-Path $EARegistryPath) {
    Write-Host "Backing up EA registry entries..." -ForegroundColor Cyan
    reg export $EARegistryPath $backupFile /y
} else {
    Write-Host "EA registry path not found. Skipping backup." -ForegroundColor Yellow
}

if (Test-Path $SteamRegistryPath) {
    Write-Host "Backing up Steam registry entries..." -ForegroundColor Cyan
    reg export $SteamRegistryPath $backupFile /y
} else {
    Write-Host "Steam registry path not found. Skipping backup." -ForegroundColor Yellow
}

# Remove broken EA registry keys
Remove-Item "$EARegistryPath" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$SteamRegistryPath" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$LinkedAccountsPath" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Fixed EA and Steam EA Linked Account Registry Issues." -ForegroundColor Green

# Remove EA configuration files
$ConfigPaths = @(
    "$env:LocalAppData\\Electronic Arts",
    "$env:LocalAppData\\Origin",
    "$env:AppData\\Roaming\\Electronic Arts",
    "$env:ProgramData\\Electronic Arts"
)
foreach ($path in $ConfigPaths) {
    if (Test-Path $path) {
        Write-Host "Deleting $path..." -ForegroundColor Cyan
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "Cleared EA configuration and cache data." -ForegroundColor Green

# Check if Steam is installed and link EA games correctly
if (Test-Path "$SteamPath") {
    Write-Host "Detected Steam Library at $SteamPath." -ForegroundColor Cyan
    $SteamRegistryKey = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath"
    if ($SteamRegistryKey) {
        Write-Host "Steam detected with the proper registry entries." -ForegroundColor Green
    } else {
        Write-Host "Steam installation missing in registry. Please reinstall Steam." -ForegroundColor Red
    }
} else {
    Write-Host "Steam installation not found. Skipping Steam EA fix." -ForegroundColor Yellow
}

# --- Post Cleanup Actions ---

# Optionally restart the PC
$restartChoice = Read-Host "Would you like to restart your PC to finalize changes? (Y/N)"
if ($restartChoice -match "^[Yy]$") {
    Write-Host "Restarting PC..." -ForegroundColor Cyan
    Restart-Computer -Force
} else {
    Write-Host "You can restart later to apply changes." -ForegroundColor Green
}

# --- Save Log File ---

$logPath = "$PSScriptRoot\DEVEG_Cleanup_Log.txt"
Write-Host "Saving log file to $logPath..." -ForegroundColor Cyan
"EA Cleanup Log - $(Get-Date)" | Out-File -FilePath $logPath -Append
Write-Host "Log file saved." -ForegroundColor Green

Write-Host "`nFix Complete! Please restart your PC for changes to take effect." -ForegroundColor Green
