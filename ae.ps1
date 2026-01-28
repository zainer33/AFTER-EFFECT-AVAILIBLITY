# ==============================================
# Lazyy Fonts Installer Menu
# Author: lazyy
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
$TempDir = "$PSScriptRoot\LazyyFontsTemp"
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

# -------------------- FONT LIST --------------------
$FontDir = "$env:WINDIR\Fonts"
$Fonts = @{
    "Komika Axis"       = "https://dl.dafont.com/dl/?f=komika_axis"
    "Designer"          = "https://dl.dafont.com/dl/?f=designer_2"
    "Altone"            = "https://dl.dafont.com/dl/?f=altone"
    "Call Of Ops Duty"  = "https://dl.dafont.com/dl/?f=call_of_ops_duty"
    "New Year Goo"      = "https://dl.dafont.com/dl/?f=newyear_goo"
}

# -------------------- MENU --------------------
do {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "           Lazyy Fonts Installer" -ForegroundColor Cyan
    Write-Host "============================================="
    Write-Host "1 : Install Fonts"
    Write-Host "0 : Quit"
    $choice = Read-Host "Enter your choice (0 or 1)"

    switch ($choice) {
        "1" {
            Write-Host "`n⬇ Installing Fonts..." -ForegroundColor Yellow
            foreach ($fontName in $Fonts.Keys) {
                $url = $Fonts[$fontName]
                $zipPath = "$TempDir\$($fontName -replace ' ','_').zip"
                Write-Host "Downloading $fontName..."
                Invoke-WebRequest $url -OutFile $zipPath -UseBasicParsing -Verbose

                $extractPath = "$TempDir\$($fontName -replace ' ','_')"
                Expand-Archive -Force $zipPath $extractPath

                # Copy .ttf and .otf files to Windows Fonts folder
                Get-ChildItem $extractPath -Include *.ttf, *.otf -Recurse | ForEach-Object {
                    Copy-Item $_.FullName $FontDir -Force
                }
            }
            Write-Host "`n✅ All fonts installed successfully!" -ForegroundColor Green
            Remove-Item $TempDir -Recurse -Force
            pause
        }
        "0" { Write-Host "Exiting..." -ForegroundColor Cyan }
        default { Write-Host "❌ Invalid choice! Try again." -ForegroundColor Red; pause }
    }

} while ($choice -ne "0")
