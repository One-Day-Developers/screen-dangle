# OD2 Screen Dangle | 1-Click Windows Command Line Installer
# https://od2.in/screen-dangle

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  OD2 Screen Dangle | Desktop Companion Setup Installer" -ForegroundColor Green
Write-Host "  Interactive Lucky Talisman for your Screen (Mac & Windows)" -ForegroundColor Gray
Write-Host "  Website: https://od2.in/screen-dangle" -ForegroundColor DarkCyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "INSTALLATION STEPS:" -ForegroundColor Cyan
Write-Host "  [1/4] Download and extract companion to your local directory" -ForegroundColor Gray
Write-Host "  [2/4] Create Desktop and Start Menu quick shortcuts" -ForegroundColor Gray
Write-Host "  [3/4] Enable instant 1-click live web sync with online studio" -ForegroundColor Gray
Write-Host "  [4/4] Launch hardware-accelerated screen dangle overlay" -ForegroundColor Gray
Write-Host ""
Write-Host "HOW TO USE YOUR SCREEN DANGLE:" -ForegroundColor Cyan
Write-Host "  * Drag & Swing  : Click and drag the hanging talisman to swing it" -ForegroundColor Gray
Write-Host "  * Click-Through : Clicks pass directly to apps underneath" -ForegroundColor Gray
Write-Host "  * Ctrl + D      : Show or hide overlay anytime" -ForegroundColor Gray
Write-Host "  * Ctrl + S      : Bless charm with gentle breeze sway" -ForegroundColor Gray
Write-Host "  * Live Web Sync : Visit https://od2.in/screen-dangle and click" -ForegroundColor Gray
Write-Host "                    'Apply to Desktop App' to instantly sync new charms" -ForegroundColor Gray
Write-Host "  * Exit App      : Right-click the OD2 icon in your system tray" -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting installation..." -ForegroundColor Yellow

$baseUrl = if ($env:OD2_BASE_URL) { $env:OD2_BASE_URL.TrimEnd('/') } else { "https://od2.in" }

# Auto-detect caller origin from PowerShell command line or history
$detectedOrigin = $null
try {
    $historyCmd = (Get-History -Count 5 -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "https?://[^/]+/screen-dangle/install\.ps1" } | Select-Object -Last 1).CommandLine
    if ($historyCmd -match "(https?://[^/]+)/screen-dangle/install\.ps1") {
        $detectedOrigin = $Matches[1]
    }
} catch {}

if (-not $detectedOrigin) {
    try {
        $psrl = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems() | Where-Object { $_ -match "https?://[^/]+/screen-dangle/install\.ps1" } | Select-Object -Last 1
        if ($psrl -match "(https?://[^/]+)/screen-dangle/install\.ps1") {
            $detectedOrigin = $Matches[1]
        }
    } catch {}
}

$activeOrigin = if ($detectedOrigin) { $detectedOrigin } elseif ($env:OD2_BASE_URL) { $env:OD2_BASE_URL.TrimEnd('/') } else { $null }

$candidateZipUrls = @(
    "https://github.com/One-Day-Developers/screen-dangle/releases/download/v1.0.0/OD2-Screen-Dangle-Windows-v1.0.0.zip"
)
if ($activeOrigin) {
    $candidateZipUrls += "$activeOrigin/api/screen-dangle/download?platform=windows-zip"
}
$candidateZipUrls += @(
    "$baseUrl/api/screen-dangle/download?platform=windows-zip",
    "http://localhost:3000/api/screen-dangle/download?platform=windows-zip"
)

$installDir = Join-Path $env:LOCALAPPDATA "Programs\OD2 Screen Dangle"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

$tempZip = Join-Path $env:TEMP "OD2-Screen-Dangle-Bundle.zip"
if (Test-Path $tempZip) {
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
}

function Download-File($url, $targetPath) {
    if (Get-Command "curl.exe" -ErrorAction SilentlyContinue) {
        try {
            & curl.exe -s -f -L -A "OD2-ScreenDangle-Installer/1.0" -o $targetPath $url
            if ((Test-Path $targetPath) -and ((Get-Item $targetPath).Length -gt 10000)) {
                return $true
            }
        } catch {}
    }

    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "OD2-ScreenDangle-Installer/1.0")
        $wc.DownloadFile($url, $targetPath)
        if ((Test-Path $targetPath) -and ((Get-Item $targetPath).Length -gt 10000)) {
            return $true
        }
    } catch {}

    try {
        Invoke-WebRequest -Uri $url -OutFile $targetPath -UserAgent "OD2-ScreenDangle-Installer/1.0" -UseBasicParsing -ErrorAction Stop
        if ((Test-Path $targetPath) -and ((Get-Item $targetPath).Length -gt 10000)) {
            return $true
        }
    } catch {}

    return $false
}

$downloaded = $false
foreach ($url in $candidateZipUrls) {
    if (Download-File -url $url -targetPath $tempZip) {
        $downloaded = $true
        break
    }
}

if ($downloaded -and (Test-Path $tempZip)) {
    Write-Host "[1/4] Extracting companion files to $installDir..." -ForegroundColor Cyan
    Unblock-File -Path $tempZip -ErrorAction SilentlyContinue

    # Close any existing running companion instances
    Get-Process -Name "OD2-Screen-Dangle*", "OD2 Screen Dangle*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300

    try {
        Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
    } catch {
        # Fallback to .NET ZipFile
        [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $installDir)
    }

    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue

    # Ensure standalone executable exists
    $stdExe = Join-Path $installDir "OD2-Screen-Dangle.exe"
    $dangleVerExe = Join-Path $installDir "OD2-Screen-Dangle-v1.0.0.exe"

    try {
        if (Test-Path $dangleVerExe) {
            Copy-Item $dangleVerExe -Destination $stdExe -Force -ErrorAction Stop
        }
    } catch {}

    # If $stdExe still doesn't exist, search for any matching exe in $installDir
    if (-not (Test-Path $stdExe)) {
        $foundExe = Get-ChildItem -Path $installDir -Filter "*.exe" | Where-Object { $_.Name -notmatch "Setup" } | Select-Object -First 1
        if ($foundExe) {
            try {
                Copy-Item $foundExe.FullName -Destination $stdExe -Force -ErrorAction Stop
            } catch {}
        }
    }

    # Unblock all extracted binaries to satisfy Windows Application Control
    Get-ChildItem -Path $installDir -Recurse | ForEach-Object {
        Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue
    }

    Write-Host "[2/4] Creating Desktop and Start Menu shortcuts..." -ForegroundColor Cyan
    try {
        $wshShell = New-Object -ComObject WScript.Shell

        # Desktop Shortcut
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $deskShortcut = $wshShell.CreateShortcut((Join-Path $desktopPath "OD2 Screen Dangle.lnk"))
        $deskShortcut.TargetPath = $stdExe
        $deskShortcut.WorkingDirectory = $installDir
        $deskShortcut.Description = "OD2 Screen Dangle | Interactive Desktop Companion v1.0.0"
        $deskShortcut.IconLocation = "$stdExe,0"
        $deskShortcut.Save()

        # Start Menu Shortcut
        $startMenuPath = [Environment]::GetFolderPath("Programs")
        $startShortcut = $wshShell.CreateShortcut((Join-Path $startMenuPath "OD2 Screen Dangle.lnk"))
        $startShortcut.TargetPath = $stdExe
        $startShortcut.WorkingDirectory = $installDir
        $startShortcut.Description = "OD2 Screen Dangle | Interactive Desktop Companion v1.0.0"
        $startShortcut.IconLocation = "$stdExe,0"
        $startShortcut.Save()
    } catch {}

    Write-Host "[3/4] Enabling instant 1-click live web sync..." -ForegroundColor Cyan
    try {
        foreach ($proto in @("od2-screendangle", "od2-screencharm")) {
            $protoKey = "HKCU:\Software\Classes\$proto"
            New-Item -Path $protoKey -Force | Out-Null
            Set-ItemProperty -Path $protoKey -Name "(default)" -Value "URL:OD2 Screen Dangle Protocol"
            Set-ItemProperty -Path $protoKey -Name "URL Protocol" -Value ""
            
            $iconKey = "$protoKey\DefaultIcon"
            New-Item -Path $iconKey -Force | Out-Null
            Set-ItemProperty -Path $iconKey -Name "(default)" -Value "`"$stdExe`",0"

            $cmdKey = "$protoKey\shell\open\command"
            New-Item -Path $cmdKey -Force | Out-Null
            Set-ItemProperty -Path $cmdKey -Name "(default)" -Value "`"$stdExe`" `"%1`""
        }
    } catch {}

    # Configure auto-start
    try {
        $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        Set-ItemProperty -Path $runKey -Name "OD2 Screen Dangle" -Value "`"$stdExe`" --autostart" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $runKey -Name "OD2 Screen Charm" -ErrorAction SilentlyContinue
    } catch {}

    # Write local uninstaller script and batch runner into $installDir
    try {
        $localUninstallerPs1 = Join-Path $installDir "uninstall.ps1"
        $uninstallerContent = @'
# OD2 Screen Dangle | Local Companion Uninstaller
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Closing OD2 Screen Dangle instances..." -ForegroundColor Yellow
Get-Process -Name "OD2-Screen-Dangle*", "OD2 Screen Dangle*", "OD2-Screen-Charm*", "OD2 Screen Charm*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 400

Write-Host "Cleaning auto-start and uninstall registry keys..." -ForegroundColor Yellow
try {
    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Remove-ItemProperty -Path $runKey -Name "OD2 Screen Dangle" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $runKey -Name "OD2ScreenDangle" -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OD2ScreenDangle" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OD2ScreenCharm" -Recurse -Force -ErrorAction SilentlyContinue
} catch {}

Write-Host "Cleaning shortcuts..." -ForegroundColor Yellow
$d1 = Join-Path ([Environment]::GetFolderPath("Desktop")) "OD2 Screen Dangle.lnk"
$d2 = Join-Path ([Environment]::GetFolderPath("Desktop")) "OD2 Screen Charm.lnk"
$p1 = Join-Path ([Environment]::GetFolderPath("Programs")) "OD2 Screen Dangle.lnk"
$p2 = Join-Path ([Environment]::GetFolderPath("Programs")) "OD2 Screen Charm.lnk"
if (Test-Path $d1) { Remove-Item $d1 -Force -ErrorAction SilentlyContinue }
if (Test-Path $d2) { Remove-Item $d2 -Force -ErrorAction SilentlyContinue }
if (Test-Path $p1) { Remove-Item $p1 -Force -ErrorAction SilentlyContinue }
if (Test-Path $p2) { Remove-Item $p2 -Force -ErrorAction SilentlyContinue }

try {
    Remove-Item -Path "HKCU:\Software\Classes\od2-screendangle" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Classes\od2-screencharm" -Recurse -Force -ErrorAction SilentlyContinue
} catch {}

$targetDir = Join-Path $env:LOCALAPPDATA "Programs\OD2 Screen Dangle"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c timeout /t 1 /nobreak >nul & rd /s /q `"$targetDir`"" -WindowStyle Hidden
Write-Host "OD2 Screen Dangle removed successfully." -ForegroundColor Green
'@
        [System.IO.File]::WriteAllText($localUninstallerPs1, $uninstallerContent, [System.Text.Encoding]::UTF8)

        $localUninstallerCmd = Join-Path $installDir "uninstall.cmd"
        $cmdContent = "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"%~dp0uninstall.ps1`"`r`n"
        [System.IO.File]::WriteAllText($localUninstallerCmd, $cmdContent, [System.Text.Encoding]::ASCII)
    } catch {}

    # Register in Windows Settings > Apps > Installed Apps & Add/Remove Programs
    try {
        $uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OD2ScreenDangle"
        New-Item -Path $uninstallKey -Force | Out-Null
        Set-ItemProperty -Path $uninstallKey -Name "DisplayName" -Value "OD2 Screen Dangle"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayVersion" -Value "1.0.0"
        Set-ItemProperty -Path $uninstallKey -Name "Publisher" -Value "One Day Developers (OD2)"
        Set-ItemProperty -Path $uninstallKey -Name "DisplayIcon" -Value "$stdExe,0"
        Set-ItemProperty -Path $uninstallKey -Name "InstallLocation" -Value $installDir
        Set-ItemProperty -Path $uninstallKey -Name "UninstallString" -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$installDir\uninstall.ps1`""
        Set-ItemProperty -Path $uninstallKey -Name "QuietUninstallString" -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$installDir\uninstall.ps1`""
        Set-ItemProperty -Path $uninstallKey -Name "URLInfoAbout" -Value "https://od2.in/screen-dangle"
        Set-ItemProperty -Path $uninstallKey -Name "HelpLink" -Value "https://od2.in/screen-dangle"
        Set-ItemProperty -Path $uninstallKey -Name "EstimatedSize" -Value 12000
        Set-ItemProperty -Path $uninstallKey -Name "NoModify" -Value 1 -Type DWord
        Set-ItemProperty -Path $uninstallKey -Name "NoRepair" -Value 1 -Type DWord
    } catch {}

    Write-Host "[4/4] Launching OD2 Screen Dangle..." -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  [SUCCESS] OD2 Screen Dangle v1.0.0 Installed Successfully!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Location : $installDir" -ForegroundColor Gray
    Write-Host "  Shortcut : Desktop -> OD2 Screen Dangle.lnk" -ForegroundColor Gray
    Write-Host ""
    Write-Host "QUICK START & CONTROLS:" -ForegroundColor Yellow
    Write-Host "  * Drag Dangle  : Left-click and drag with your mouse" -ForegroundColor White
    Write-Host "  * Ctrl + D     : Toggle show / hide screen overlay" -ForegroundColor White
    Write-Host "  * Ctrl + S     : Bless charm with gentle air sway" -ForegroundColor White
    Write-Host "  * Web Studio   : Open https://od2.in/screen-dangle to customize" -ForegroundColor White
    Write-Host "                   colors or upload custom PNG/SVG avatars" -ForegroundColor White
    Write-Host "  * System Tray  : Right-click tray icon to change presets or exit" -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan

    if (Test-Path $stdExe) {
        try {
            Start-Process -FilePath $stdExe -WorkingDirectory $installDir
        } catch {
            & $stdExe
        }
    } else {
        Write-Host "Companion installed. Please launch via your Desktop shortcut." -ForegroundColor Yellow
    }

    # Silent background install telemetry ping
    try {
        $telemetryBody = @{
            platform = "windows"
            action = "install"
            arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
            osVersion = [System.Environment]::OSVersion.VersionString
            appType = "windows-native"
            presetId = "nazar"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "https://od2.in/api/screen-dangle/telemetry" -Method Post -Body $telemetryBody -ContentType "application/json" -TimeoutSec 3 -ErrorAction SilentlyContinue | Out-Null
    } catch {}
} else {
    Write-Host "Could not download OD2 Screen Dangle package. Please check your internet connection or download manually from: https://od2.in/screen-dangle" -ForegroundColor Red
    Write-Error "Failed to download OD2 Screen Dangle package."
}

