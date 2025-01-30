@echo off
cls

:: Set console background color to purple (5F)
color 5F

:: Create a big title using ASCII art
echo.
echo      DDDD    EEEEE    V   V    EEEEE    GGG   EA & Origin Cleaner
echo      D   D   E        V   V    E       G       E   A   Cleaner
echo      D   D   EEEE     V   V    EEEE    G  GG   EA   Cleaner  
echo      D   D   E        V   V    E       G   G    E   A  Cleaner
echo      DDDD    EEEEE    V   V    EEEEE    GGG    EA   Cleaner
echo.

:: Display the title again at the bottom of the script to keep it visible
setlocal enabledelayedexpansion

:: Set log file path
set LOGFILE=%~dp0DEVEG_Cleanup_Log.txt
echo ============================== > "%LOGFILE%"
echo DEVEG EA & Origin Cleaner Log  >> "%LOGFILE%"
echo ============================== >> "%LOGFILE%"
echo Log Start Time: %DATE% %TIME%  >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Function to add colorized text
call :set_colors
call :echo_info "Running as administrator..."

:: Check if EA App or Origin is installed
call :check_software_installed "EA App"
call :check_software_installed "Origin"

:: Check if EA games installed via Steam
call :check_for_steam_install

echo ================================================
echo  DEVEG EA & Origin Cleaner - Fixes EA App Issues
echo ================================================
echo Log file: %LOGFILE%
echo.
echo [INFO] This script will clean up EA and Origin traces to fix game launch issues.
echo Please follow the on-screen instructions.
pause

:: Step 1: Stop EA & Origin Processes
call :stop_processes

:: Step 2: Uninstall EA & Origin
call :uninstall_software

:: Step 3: Clean Registry Entries
call :clean_registry

:: Step 4: Delete Leftover Files
call :delete_leftover_files

:: Step 5: Flush DNS Cache
call :flush_dns

:: Step 6: Restart Windows Explorer
call :restart_explorer

:: Check and log remaining issues after steps
call :check_remaining_issues

:: Final message to the user
echo [DONE] Cleanup complete!
call :echo_info "Cleanup complete!"
echo [INFO] Please restart your computer before reinstalling EA App.
echo [INFO] Please restart your computer before reinstalling EA App. >> "%LOGFILE%"
echo Log End Time: %DATE% %TIME% >> "%LOGFILE%"
pause
exit

:: Function to set colors for terminal output
:set_colors
    color 5F
    exit /b

:: Function to print info message in green
:echo_info
    echo %1
    echo %1 >> "%LOGFILE%"
    exit /b

:: Function to print warning message in yellow
:echo_warning
    color 0E
    echo %1
    echo %1 >> "%LOGFILE%"
    color 5F
    exit /b

:: Function to print error message in red
:echo_error
    color 0C
    echo %1
    echo %1 >> "%LOGFILE%"
    color 5F
    exit /b

:: Function to check if EA App or Origin is installed
:check_software_installed
    set SOFTWARE_NAME=%1
    echo [INFO] Checking if %SOFTWARE_NAME% is installed...
    echo [INFO] Checking if %SOFTWARE_NAME% is installed... >> "%LOGFILE%"
    wmic product where "name like '%%%SOFTWARE_NAME%%'" get Name, Version > nul
    if errorlevel 1 (
        call :echo_warning "%SOFTWARE_NAME% not found."
    ) else (
        call :echo_info "%SOFTWARE_NAME% found, proceeding with cleanup."
    )
    exit /b

:: Function to check if EA games are installed through Steam
:check_for_steam_install
    echo [INFO] Checking if EA games are installed through Steam...
    echo [INFO] Checking if EA games are installed through Steam... >> "%LOGFILE%"
    set STEAM_PATH="C:\Program Files (x86)\Steam\steamapps\common"
    if exist %STEAM_PATH%\*.exe (
        call :echo_info "EA Games found via Steam at %STEAM_PATH%. Proceeding with cleanup."
    ) else (
        call :echo_warning "No EA games found in Steam directory."
    )
    exit /b

:: Function to stop EA & Origin processes
:stop_processes
    call :progress_bar "Stopping EA & Origin processes" 0 5
    taskkill /F /IM EADesktop.exe >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "EADesktop.exe found and stopped."
    ) else (
        call :echo_warning "EADesktop.exe not found."
    )

    taskkill /F /IM Origin.exe >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Origin.exe found and stopped."
    ) else (
        call :echo_warning "Origin.exe not found."
    )

    taskkill /F /IM OriginClientService.exe >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "OriginClientService.exe found and stopped."
    ) else (
        call :echo_warning "OriginClientService.exe not found."
    )

    taskkill /F /IM EALauncher.exe >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "EALauncher.exe found and stopped."
    ) else (
        call :echo_warning "EALauncher.exe not found."
    )

    taskkill /F /IM EAUpdater.exe >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "EAUpdater.exe found and stopped."
    ) else (
        call :echo_warning "EAUpdater.exe not found."
    )

    call :progress_bar "Stopping processes" 5 10
    echo [DONE] All processes stopped. >> "%LOGFILE%"
    echo [DONE] All processes stopped.
    exit /b

:: Function to uninstall EA & Origin
:uninstall_software
    call :progress_bar "Uninstalling EA & Origin" 0 10
    wmic product where "name like '%%EA App%%'" call uninstall /nointeractive >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "EA App uninstalled successfully."
    ) else (
        call :echo_warning "EA App not found for uninstallation."
    )

    wmic product where "name like '%%Origin%%'" call uninstall /nointeractive >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Origin uninstalled successfully."
    ) else (
        call :echo_warning "Origin not found for uninstallation."
    )

    call :progress_bar "Uninstalling EA & Origin" 10 20
    echo [DONE] Uninstallation complete. >> "%LOGFILE%"
    echo [DONE] Uninstallation complete.
    exit /b

:: Function to clean registry entries
:clean_registry
    call :progress_bar "Cleaning registry entries" 0 15
    reg delete "HKCU\Software\Electronic Arts" /f >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Electronic Arts registry entry in HKCU."
    ) else (
        call :echo_warning "Electronic Arts registry entry not found in HKCU."
    )

    reg delete "HKCU\Software\Origin" /f >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Origin registry entry in HKCU."
    ) else (
        call :echo_warning "Origin registry entry not found in HKCU."
    )

    reg delete "HKLM\SOFTWARE\Electronic Arts" /f >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Electronic Arts registry entry in HKLM."
    ) else (
        call :echo_warning "Electronic Arts registry entry not found in HKLM."
    )

    reg delete "HKLM\SOFTWARE\WOW6432Node\Electronic Arts" /f >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Electronic Arts registry entry in WOW6432Node."
    ) else (
        call :echo_warning "Electronic Arts registry entry not found in WOW6432Node."
    )

    call :progress_bar "Cleaning registry entries" 15 25
    echo [DONE] Registry cleaned. >> "%LOGFILE%"
    echo [DONE] Registry cleaned.
    exit /b

:: Function to delete leftover files
:delete_leftover_files
    call :progress_bar "Deleting EA & Origin files" 0 20
    rd /s /q "%ProgramData%\Electronic Arts" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Electronic Arts directory from ProgramData."
    ) else (
        call :echo_warning "Electronic Arts directory not found in ProgramData."
    )

    rd /s /q "%ProgramData%\Origin" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Origin directory from ProgramData."
    ) else (
        call :echo_warning "Origin directory not found in ProgramData."
    )

    rd /s /q "%AppData%\Local\Electronic Arts" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Electronic Arts directory from AppData."
    ) else (
        call :echo_warning "Electronic Arts directory not found in AppData."
    )

    rd /s /q "%AppData%\Roaming\Electronic Arts" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Roaming/Electronic Arts directory from AppData."
    ) else (
        call :echo_warning "Roaming/Electronic Arts directory not found in AppData."
    )

    rd /s /q "%AppData%\Local\Origin" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Local/Origin directory from AppData."
    ) else (
        call :echo_warning "Local/Origin directory not found in AppData."
    )

    rd /s /q "%AppData%\Roaming\Origin" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_info "Deleted Roaming/Origin directory from AppData."
    ) else (
        call :echo_warning "Roaming/Origin directory not found in AppData."
    )

    call :progress_bar "Deleting files" 20 30
    echo [DONE] Files deleted. >> "%LOGFILE%"
    echo [DONE] Files deleted.
    exit /b

:: Function to flush DNS
:flush_dns
    call :progress_bar "Flushing DNS cache" 0 5
    ipconfig /flushdns >> "%LOGFILE%" 2>&1
    call :echo_info "DNS cache flushed."
    exit /b

:: Function to restart Windows Explorer
:restart_explorer
    call :progress_bar "Restarting Windows Explorer" 0 5
    taskkill /f /im explorer.exe >> "%LOGFILE%" 2>&1
    start explorer.exe >> "%LOGFILE%" 2>&1
    call :echo_info "Windows Explorer restarted."
    exit /b

:: Function to check for remaining issues
:check_remaining_issues
    call :progress_bar "Checking remaining issues" 0 5
    tasklist | findstr /i "origin" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        call :echo_warning "Some Origin processes are still running."
    ) else (
        call :echo_info "No Origin processes found running."
    )
    exit /b

:: Function to show a progress bar
:progress_bar
    echo %1
    for /l %%i in (%2, 1, %3) do (
        set /a "percent=%%i*100/(%3-%2)"
        set "bar="
        for /l %%j in (1, 1, %%i) do set "bar=!bar!#"
        set "spaces=                                                                                                  "
        echo [%%i/%3] !bar!!spaces:~0,30! %percent%%%...
    )
    exit /b
