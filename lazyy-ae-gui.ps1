# ==============================================
# Lazyy AE Installer GUI
# Author: lazyy
# ==============================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-Message($msg, $title="Lazyy AE Installer") {
    [System.Windows.Forms.MessageBox]::Show($msg, $title)
}

# Ensure admin
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Show-Message "This script must be run as Administrator!"
    exit
}

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Lazyy AE Installer"
$form.Size = New-Object System.Drawing.Size(450,300)
$form.StartPosition = "CenterScreen"

# Buttons
$btnFonts = New-Object System.Windows.Forms.Button
$btnFonts.Text = "Install Fonts"
$btnFonts.Size = New-Object System.Drawing.Size(150, 40)
$btnFonts.Location = New-Object System.Drawing.Point(30,30)

$btnPlugin = New-Object System.Windows.Forms.Button
$btnPlugin.Text = "Install Deep Glow Plugin"
$btnPlugin.Size = New-Object System.Drawing.Size(200, 40)
$btnPlugin.Location = New-Object System.Drawing.Point(200,30)

$comboAE = New-Object System.Windows.Forms.ComboBox
$comboAE.Location = New-Object System.Drawing.Point(30,100)
$comboAE.Size = New-Object System.Drawing.Size(370,30)

# Detect AE Installations
$aePaths = @()
$possible = Get-ChildItem "C:\Program Files\Adobe\" -Directory -ErrorAction SilentlyContinue
foreach ($d in $possible) {
    if (Test-Path "$($d.FullName)\Support Files\Plug-ins") {
        $aePaths += "$($d.FullName)\Support Files\Plug-ins"
    }
}
if ($aePaths.Count -eq 0) {
    $aePaths = @("No AE detected")
}
$comboAE.Items.AddRange($aePaths)
$comboAE.SelectedIndex = 0

$form.Controls.Add($btnFonts)
$form.Controls.Add($btnPlugin)
$form.Controls.Add($comboAE)

# Font Installation Logic
$btnFonts.Add_Click({
    $Temp = "$PSScriptRoot\LazyyFonts"
    New-Item -Path $Temp -ItemType Directory -Force | Out-Null
    $fonts = @{
        "Komika Axis"       = "https://dl.dafont.com/dl/?f=komika_axis"
        "Designer"          = "https://dl.dafont.com/dl/?f=designer_2"
        "Altone"            = "https://dl.dafont.com/dl/?f=altone"
        "Call Of Ops Duty"  = "https://dl.dafont.com/dl/?f=call_of_ops_duty"
        "New Year Goo"      = "https://dl.dafont.com/dl/?f=newyear_goo"
    }
    foreach ($key in $fonts.Keys) {
        $url = $fonts[$key]
        $zip = "$Temp\$($key -replace ' ','_').zip"
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        Expand-Archive -Force $zip -DestinationPath "$Temp\$($key -replace ' ','_')" 
        Get-ChildItem "$Temp\$($key -replace ' ','_')" -Include *.ttf, *.otf -Recurse | ForEach-Object {
            Copy-Item $_ "$env:WINDIR\Fonts" -Force
        }
    }
    Remove-Item $Temp -Recurse -Force
    Show-Message "Fonts Installed Successfully!"
})

# Plugin Install Logic
$btnPlugin.Add_Click({

    # Mega downloader
    $megaExe = "$PSScriptRoot\megadl.exe"
    if (-not (Test-Path $megaExe)) {
        Show-Message "Downloading Mega downloader..."
        Invoke-WebRequest "https://github.com/megous/megatools/releases/latest/download/megatools-win64.zip" -OutFile "$PSScriptRoot\megatools.zip"
        Expand-Archive -Force "$PSScriptRoot\megatools.zip" "$PSScriptRoot"
        Move-Item "$PSScriptRoot\megatools-win64\megadl.exe" $megaExe
        Remove-Item "$PSScriptRoot\megatools-win64" -Recurse
        Remove-Item "$PSScriptRoot\megatools.zip"
    }

    $deepGlowMega = "https://mega.nz/file/T9B3nLxT#GG8zz9oa3RM28TEJiwwi8QexMraCOUjo2PN1tfEGsWs"
    $destZip = "$PSScriptRoot\deepglow.zip"

    Show-Message "Downloading Deep Glow plugin..."
    Start-Process -NoNewWindow -Wait -FilePath $megaExe -ArgumentList " $deepGlowMega -o $destZip"

    Expand-Archive -Force $destZip "$PSScriptRoot\deepglow"

    $chosenPath = $comboAE.SelectedItem
    if ($chosenPath -eq "No AE detected") {
        Show-Message "After Effects not found!"
        return
    }

    Get-ChildItem "$PSScriptRoot\deepglow" -Include *.aex -Recurse | ForEach-Object {
        Copy-Item $_.FullName $chosenPath -Force
    }

    Remove-Item "$PSScriptRoot\deepglow" -Recurse -Force
    Remove-Item $destZip -Force

    Show-Message "Deep Glow Installed Successfully!"
})

$form.ShowDialog()
