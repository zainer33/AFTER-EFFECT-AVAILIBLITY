# ==============================================
# Lazyy AE Installer Interactive
# Author: lazyy
# Features: Fonts & Deep Glow Plugin installation
# ==============================================

# -------------------- ADMIN CHECK --------------------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Please run as Administrator!" -ForegroundColor Red
    pause
    exit
}

# -------------------- TEMP FOLDER --------------------
$TempDir = "$PSScriptRoot\LazyyTemp"
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

# -------------------- USER PROMPT --------------------
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "          Lazyy AE Installer" -ForegroundColor Cyan
Write-Host "============================================="
Write-Host "What do you want to download/install?"
Write-Host "1. Fonts only"
Write-Host "2. Deep Glow Plugin only"
Write-Host "3. Both Fonts + Deep Glow Plugin"
$choice = Read-Host "Enter 1, 2, or 3"

# -------------------- FONTS FUNCTION --------------------
function Install-Fonts {
    $FontDir = "$env:WINDIR\Fonts"
    $Fonts = @{
        "Komika Axis"       = "https://dl.dafont.com/dl/?f=komika_axis"
        "Designer"          = "https://dl.dafont.com/dl/?f=designer_2"
        "Altone"            = "https://dl.dafont.com/dl/?f=altone"
        "Call Of Ops Duty"  = "https://dl.dafont.com/dl/?f=call_of_ops_duty"
        "New Year Goo"      = "https://dl.dafont.com/dl/?f=newyear_goo"
    }

    Write-Host "`n⬇ Installing Fonts..." -ForegroundColor Yellow
    foreach ($fontName in $Fonts.Keys) {
        $url = $Fonts[$fontName]
        $zipPath = "$TempDir\$($fontName -replace ' ','_').zip"
        Write-Host "Downloading $fontName..."
        Invoke-WebRequest $url -OutFile $zipPath -UseBasicParsing -Verbose
        $extractPath = "$TempDir\$($fontName -replace ' ','_')"
        Expand-Archive -Force $zipPath $extractPath
        Get-ChildItem $extractPath -Include *.ttf, *.otf -Recurse | ForEach-Object {
            Copy-Item $_.FullName $FontDir -Force
        }
    }
    Write-Host "`n✅ Fonts installed successfully!" -ForegroundColor Green
}

# -------------------- PLUGIN FUNCTION --------------------
function Install-Plugin {
    Write-Host "`n⬇ Installing Deep Glow Plugin..." -ForegroundColor Yellow

    # Detect After Effects Plugins folder
    $AEPluginsPath = $null
    $PossibleAE = Get-ChildItem "C:\Program Files\Adobe\" -Directory -ErrorAction SilentlyContinue
    foreach ($d in $PossibleAE) {
        $pluginFolder = Join-Path $d.FullName "Support Files\Plug-ins"
        if (Test-Path $pluginFolder) {
            $AEPluginsPath = $pluginFolder
            break
        }
    }

    if (-not $AEPluginsPath) {
        Write-Host "❌ After Effects not found!" -ForegroundColor Red
        return
    }

    # Mega downloader
    $MegaExe = "$PSScriptRoot\megadl.exe"
    if (-not (Test-Path $MegaExe)) {
        Write-Host "Downloading Mega downloader..."
        $MegaZip = "$TempDir\megatools.zip"
        Invoke-WebRequest "https://github.com/megous/megatools/releases/latest/download/megatools-win64.zip" -OutFile $MegaZip
        Expand-Archive -Force $MegaZip $TempDir
        Move-Item "$TempDir\megatools-win64\megadl.exe" $MegaExe
        Remove-Item "$TempDir\megatools-win64" -Recurse
        Remove-Item $MegaZip
    }

    $MegaUrl = "https://mega.nz/file/T9B3nLxT#GG8zz9oa3RM28TEJiwwi8QexMraCOUjo2PN1tfEGsWs"
    $PluginFile = "$TempDir\DeepGlow.aex"

    Write-Host "Downloading Deep Glow plugin..."
    Start-Process -FilePath $MegaExe -ArgumentList " $MegaUrl -o $PluginFile" -NoNewWindow -Wait

    Write-Host "Copying plugin to AE Plugins folder..."
    Copy-Item $PluginFile $AEPluginsPath -Force

    Write-Host "`n✅ Deep Glow installed successfully!" -ForegroundColor Green
}

# -------------------- EXECUTE BASED ON USER CHOICE --------------------
switch ($choice) {
    "1" { Install-Fonts }
    "2" { Install-Plugin }
    "3" { Install-Fonts; Install-Plugin }
    default { Write-Host "❌ Invalid option, exiting." -ForegroundColor Red; exit }
}

# -------------------- CLEANUP --------------------
Remove-Item $TempDir -Recurse -Force
Write-Host "`n🎉 All selected tasks completed!" -ForegroundColor Cyan
pause
