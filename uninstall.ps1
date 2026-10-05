# OD2 Screen Dangle | 1-Click Windows Uninstaller
# https://od2.in/screen-dangle

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  OD2 Screen Dangle | Windows Companion Uninstaller" -ForegroundColor Green
Write-Host "  Website: https://od2.in/screen-dangle" -ForegroundColor DarkCyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Closing running instances..." -ForegroundColor Yellow
Get-Process -Name "OD2-Screen-Dangle*", "OD2 Screen Dangle*", "OD2-Screen-Charm*", "OD2 Screen Charm*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 400

Write-Host "Removing auto-start registry entries..." -ForegroundColor Yellow
try {
    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Remove-ItemProperty -Path $runKey -Name "OD2 Screen Dangle" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $runKey -Name "OD2ScreenDangle" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $runKey -Name "OD2 Screen Charm" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $runKey -Name "OD2ScreenCharm" -ErrorAction SilentlyContinue
} catch {}

Write-Host "Removing Windows Settings Installed Apps registration..." -ForegroundColor Yellow
try {
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OD2ScreenDangle" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OD2ScreenCharm" -Recurse -Force -ErrorAction SilentlyContinue
} catch {}

Write-Host "Removing desktop and start menu shortcuts..." -ForegroundColor Yellow
$desktopShortcut1 = Join-Path ([Environment]::GetFolderPath("Desktop")) "OD2 Screen Dangle.lnk"
$desktopShortcut2 = Join-Path ([Environment]::GetFolderPath("Desktop")) "OD2 Screen Charm.lnk"
if (Test-Path $desktopShortcut1) { Remove-Item $desktopShortcut1 -Force -ErrorAction SilentlyContinue }
if (Test-Path $desktopShortcut2) { Remove-Item $desktopShortcut2 -Force -ErrorAction SilentlyContinue }

$startMenuShortcut1 = Join-Path ([Environment]::GetFolderPath("Programs")) "OD2 Screen Dangle.lnk"
$startMenuShortcut2 = Join-Path ([Environment]::GetFolderPath("Programs")) "OD2 Screen Charm.lnk"
if (Test-Path $startMenuShortcut1) { Remove-Item $startMenuShortcut1 -Force -ErrorAction SilentlyContinue }
if (Test-Path $startMenuShortcut2) { Remove-Item $startMenuShortcut2 -Force -ErrorAction SilentlyContinue }

Write-Host "Removing protocol handler registry keys..." -ForegroundColor Yellow
try {
    Remove-Item -Path "HKCU:\Software\Classes\od2-screendangle" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Classes\od2-screencharm" -Recurse -Force -ErrorAction SilentlyContinue
} catch {}

Write-Host "Removing installed companion files..." -ForegroundColor Yellow
$installDir = Join-Path $env:LOCALAPPDATA "Programs\OD2 Screen Dangle"
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { "" }

if ($scriptDir -and (Test-Path $installDir) -and ($scriptDir.StartsWith($installDir, [System.StringComparison]::OrdinalIgnoreCase))) {
    # Running from inside the install directory: spawn detached background process to delete directory after exit
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c timeout /t 1 /nobreak >nul & rd /s /q `"$installDir`"" -WindowStyle Hidden
} else {
    if (Test-Path $installDir) {
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  [SUCCESS] OD2 Screen Dangle has been completely removed." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "All companion files, shortcuts, Windows Settings entries, and auto-start keys have been cleaned." -ForegroundColor Gray
Write-Host ""
