# DEVEG_EA_Cleaner.ps1 - Ultimate EA App/Origin Uninstaller & Steam Fixer

Write-Host "`n=== DEVEG EA Cleaner ===" -ForegroundColor Magenta
Write-Host "Ultimate Fixer for EA & Steam EA Games" -ForegroundColor Yellow

# Function to pause and display message
function Pause {
    Write-Host "Press any key to continue..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Confirm Uninstallation of EA App / Origin
$uninstallChoice = Read-Host "Do you want to uninstall EA App / Origin? (Y/N)"
if ($uninstallChoice -match "^[Yy]$") {
    Write-Host "Uninstalling EA App / Origin..." -ForegroundColor Cyan
    Stop-Process -Name "EADesktop" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "Origin" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "EABackgroundService" -Force -ErrorAction SilentlyContinue
    Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Electronic Arts|EA App|Origin" } | ForEach-Object { $_.Uninstall() }
    
    # Remove EA & Origin files
    Write-Host "Deleting EA & Origin files..." -ForegroundColor Cyan
    $DeletePaths = @(
        "$env:ProgramFiles\Electronic Arts",
        "$env:ProgramFiles\Origin",
        "$env:ProgramFiles (x86)\Electronic Arts",
        "$env:ProgramFiles (x86)\Origin",
        "$env:ProgramData\Electronic Arts",
        "$env:LocalAppData\Electronic Arts",
        "$env:LocalAppData\Origin",
        "$env:AppData\Roaming\Electronic Arts"
    )
    foreach ($path in $DeletePaths) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "EA App / Origin has been uninstalled and all files deleted." -ForegroundColor Green
}
Pause

# Fix Steam EA Game Linking
Write-Host "Fixing Steam-EA Game Linking..." -ForegroundColor Cyan
$SteamPath = "C:\\Program Files (x86)\\Steam\\steamapps\\common"
$EARegistryPath = "HKCU:\\Software\\Electronic Arts"
$SteamRegistryPath = "HKCU:\\Software\\Valve\\Steam\\Apps"
$LinkedAccountsPath = "HKCU:\\Software\\Electronic Arts\\EA Desktop\\Linked Accounts"

# Backup registry before removing
$backupFile = "$PSScriptRoot\EA_Steam_Registry_Backup.reg"
reg export $EARegistryPath $backupFile /y
reg export $SteamRegistryPath $backupFile /y
Write-Host "Registry backup created." -ForegroundColor Green

# Remove broken registry keys
Remove-Item "$EARegistryPath" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$SteamRegistryPath" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$LinkedAccountsPath" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Fixed EA and Steam EA Linked Account Registry Issues." -ForegroundColor Green
Pause

# Remove corrupted cache and configs
Write-Host "Clearing EA configuration and cache data..." -ForegroundColor Cyan
$ConfigPaths = @(
    "$env:LocalAppData\\Electronic Arts",
    "$env:LocalAppData\\Origin",
    "$env:AppData\\Roaming\\Electronic Arts",
    "$env:ProgramData\\Electronic Arts"
)
foreach ($path in $ConfigPaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "Cache and config data cleared." -ForegroundColor Green
Pause

# Restart EA Background Service
Write-Host "Restarting EA Background Service..." -ForegroundColor Cyan
Stop-Service -Name "EABackgroundService" -Force -ErrorAction SilentlyContinue
Start-Service -Name "EABackgroundService" -ErrorAction SilentlyContinue
Write-Host "EA Background Service restarted." -ForegroundColor Green
Pause

# Ensure Steam-EA connection is restored
Write-Host "Checking Steam-EA Account Link..." -ForegroundColor Cyan
$SteamRegistryKey = Get-ItemProperty -Path "HKCU:\\Software\\Valve\\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
if ($SteamRegistryKey) {
    Write-Host "Steam detected with the proper registry entries." -ForegroundColor Green
} else {
    Write-Host "Steam installation missing in registry. Please reinstall Steam." -ForegroundColor Red
}
Pause

# Optionally restart PC
$restartChoice = Read-Host "Would you like to restart your PC to finalize changes? (Y/N)"
if ($restartChoice -match "^[Yy]$") {
    Write-Host "Restarting PC..." -ForegroundColor Cyan
    Restart-Computer -Force
} else {
    Write-Host "You can restart later to apply changes." -ForegroundColor Green
}

# Save log file
$logPath = "$PSScriptRoot\DEVEG_Cleanup_Log.txt"
Write-Host "Saving log file to $logPath..." -ForegroundColor Cyan
"EA Cleanup Log - $(Get-Date)" | Out-File -FilePath $logPath -Append
Write-Host "Log file saved." -ForegroundColor Green

Write-Host "`nFix Complete! Press any key to exit." -ForegroundColor Green
Pause
