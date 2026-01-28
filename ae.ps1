# ==============================================
# Lazyy AE  Installer
# Author: lazyy
# ==============================================

# Check for admin
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Run this script as Administrator!" -ForegroundColor Red
    pause
    exit
}

# Temp folder
$TempDir = "$PSScriptRoot\LazyyTemp"
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

# -------------------- FONTS --------------------
$FontDir = "$env:WINDIR\Fonts"
$Fonts = @{
    "Komika Axis"       = "https://dl.dafont.com/dl/?f=komika_axis"
    "Designer"          = "https://dl.dafont.com/dl/?f=designer_2"
    "Altone"            = "https://dl.dafont.com/dl/?f=altone"
    "Call Of Ops Duty"  = "https://dl.dafont.com/dl/?f=call_of_ops_duty"
    "New Year Goo"      = "https://dl.dafont.com/dl/?f=newyear_goo"
}

Write-Host "`n⬇ Installing Fonts..." -ForegroundColor Yellow

foreach ($key in $Fonts.Keys) {
    $url = $Fonts[$key]
    $zipPath = "$TempDir\$($key -replace ' ','_').zip"
    Write-Host "Downloading $key..."
    Invoke-WebRequest $url -OutFile $zipPath -UseBasicParsing -Verbose
    $extractPath = "$TempDir\$($key -replace ' ','_')"
    Expand-Archive -Force $zipPath $extractPath
    Get-ChildItem $extractPath -Include *.ttf, *.otf -Recurse | ForEach-Object {
        Copy-Item $_.FullName $FontDir -Force
    }
}

Write-Host "`n✅ Fonts installed!" -ForegroundColor Green

# -------------------- PLUGIN --------------------
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
    pause
    exit
}

# Mega.nz download (requires megadl)
$MegaUrl = "https://mega.nz/file/T9B3nLxT#GG8zz9oa3RM28TEJiwwi8QexMraCOUjo2PN1tfEGsWs"
$PluginFile = "$TempDir\DeepGlow.aex"

# Check for megadl.exe
$MegaDLExe = "$PSScriptRoot\megadl.exe"
if (-not (Test-Path $MegaDLExe)) {
    Write-Host "Downloading Mega downloader..."
    $MegaZip = "$TempDir\megatools.zip"
    Invoke-WebRequest "https://github.com/megous/megatools/releases/latest/download/megatools-win64.zip" -OutFile $MegaZip
    Expand-Archive -Force $MegaZip $TempDir
    Move-Item "$TempDir\megatools-win64\megadl.exe" $MegaDLExe
    Remove-Item "$TempDir\megatools-win64" -Recurse
    Remove-Item $MegaZip
}

# Download plugin with progress
Write-Host "Downloading Deep Glow plugin..."
Start-Process -FilePath $MegaDLExe -ArgumentList " $MegaUrl -o $PluginFile" -NoNewWindow -Wait

# Copy plugin to AE Plugins folder
Copy-Item $PluginFile $AEPluginsPath -Force

# Cleanup
Remove-Item $TempDir -Recurse -Force

Write-Host "`n✅ Deep Glow installed successfully!" -ForegroundColor Green
Write-Host "🔁 Restart After Effects to see the plugin."
pause
