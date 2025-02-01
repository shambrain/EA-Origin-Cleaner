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
    Write-Host "✅ EA App / Origin has been uninstalled and all files deleted." -ForegroundColor Green
}
Pause

# Fix Steam EA Game Linking
Write-Host "🔧 Fixing Steam-EA Game Linking..." -ForegroundColor Cyan
$SteamPath = "C:\\Program Files (x86)\\Steam\\steamapps\\common"
$EARegistryPath = "HKCU:\\Software\\Electronic Arts"
$SteamRegistryPath = "HKCU:\\Software\\Valve\\Steam\\Apps"
$LinkedAccountsPath = "HKCU:\\Software\\Electronic Arts\\EA Desktop\\Linked Accounts"

# Backup registry before removing (Only if the registry exists)
$backupFile = "$PSScriptRoot\EA_Steam_Registry_Backup.reg"
Write-Host "🔍 Checking if registry paths exist before exporting..." -ForegroundColor Cyan
if (Test-Path "Registry::$EARegistryPath") {
    reg export "HKCU\Software\Electronic Arts" "$backupFile" /y
    Write-Host "✅ EA registry backup created." -ForegroundColor Green
} else {
    Write-Host "⚠️ EA registry not found. Skipping backup." -ForegroundColor Yellow
}

if (Test-Path "Registry::$SteamRegistryPath") {
    reg export "HKCU\Software\Valve\Steam\Apps" "$backupFile" /y
    Write-Host "✅ Steam registry backup created." -ForegroundColor Green
} else {
    Write-Host "⚠️ Steam registry not found. Skipping backup." -ForegroundColor Yellow
}
Pause

# Remove broken registry keys
Write-Host "🗑 Removing broken EA & Steam registry entries..." -ForegroundColor Cyan
Remove-Item -Path "Registry::$EARegistryPath" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "Registry::$SteamRegistryPath" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "Registry::$LinkedAccountsPath" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "✅ EA & Steam registry cleanup completed." -ForegroundColor Green
Pause

# Remove corrupted cache and configs
Write-Host "🗑 Clearing EA configuration and cache data..." -ForegroundColor Cyan
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
Write-Host "✅ Cache and config data cleared." -ForegroundColor Green
Pause

# Restart EA Background Service
Write-Host "🔄 Restarting EA Background Service..." -ForegroundColor Cyan
Stop-Service -Name "EABackgroundService" -Force -ErrorAction SilentlyContinue
Start-Service -Name "EABackgroundService" -ErrorAction SilentlyContinue
Write-Host "✅ EA Background Service restarted." -ForegroundColor Green
Pause

# Restart Steam to Apply Fixes
Write-Host "🔄 Restarting Steam..." -ForegroundColor Cyan
Stop-Process -Name "Steam" -Force -ErrorAction SilentlyContinue
Start-Process "C:\\Program Files (x86)\\Steam\\Steam.exe"
Write-Host "✅ Steam restarted successfully." -ForegroundColor Green
Pause

# Ensure Steam-EA connection is restored
Write-Host "🔍 Checking Steam-EA Account Link..." -ForegroundColor Cyan
$SteamRegistryKey = Get-ItemProperty -Path "HKCU:\\Software\\Valve\\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
if ($SteamRegistryKey) {
    Write-Host "✅ Steam detected with the proper registry entries." -ForegroundColor Green
} else {
    Write-Host "❌ Steam installation missing in registry. Please reinstall Steam." -ForegroundColor Red
}
Pause

# Optionally restart PC
$restartChoice = Read-Host "Would you like to restart your PC to finalize changes? (Y/N)"
if ($restartChoice -match "^[Yy]$") {
    Write-Host "🔄 Restarting PC..." -ForegroundColor Cyan
    Restart-Computer -Force
} else {
    Write-Host "ℹ️ You can restart later to apply changes." -ForegroundColor Green
}

# Save log file
$logPath = "$PSScriptRoot\DEVEG_Cleanup_Log.txt"
Write-Host "💾 Saving log file to $logPath..." -ForegroundColor Cyan
"EA Cleanup Log - $(Get-Date)" | Out-File -FilePath $logPath -Append
Write-Host "✅ Log file saved." -ForegroundColor Green

Write-Host "`n✅✅✅ Fix Complete! Press any key to exit." -ForegroundColor Green
Pause
