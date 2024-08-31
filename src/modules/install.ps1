$ErrorActionPreference = 'SilentlyContinue'
$Global:ProgressPreference = 'SilentlyContinue'
$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$fluxPath = (Join-Path $localAppData "FluxTeam")
$rbxversion = (Invoke-WebRequest -UserAgent "WEAO-3PService" -Method Get -Uri 'https://weao.xyz/api/versions/current' | ConvertFrom-Json).Windows
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$webdata = invoke-webrequest -URI "https://raw.githubusercontent.com/Shall0e/fluxteam-installer/main/data.json" | ConvertFrom-Json
$installationdata = ((Get-Content -Path (Join-Path $fluxPath "version.txt")) -split "\n")
$OriginalProgressPreference = $Global:ProgressPreference

function startProgram {
    Stop-Process -Name "FluxTeam" -Force
    Stop-Process -Name "Main" -Force
    Start-Sleep -Milliseconds 500
    Start-Process -FilePath (Join-Path $fluxPath "FluxTeam.exe")
}
function powershellEmulator {
    param (
        [bool]$On=$false,
        $Path
    )
    if ($On -eq $false) {
        Write-Host 'Currently running on Desktop, make sure to switch runningOnline to $true before publishing!' -ForegroundColor Cyan
        pause
        powershell.exe -File (Join-Path $scriptDir $Directory)
    } else {
        Invoke-RestMethod "https://raw.githubusercontent.com/Shall0e/fluxteam-installer/main/src/$Path" | Invoke-Expression
    }
}
function betterPause {
    param (
        [string]$Message,
        [string]$Color="Red"
    )
    if ($Message -ne "") {
        Write-Host $Message -ForegroundColor $Color
    }
    Write-Host ' '
    Write-Host -ForegroundColor Magenta "(Press Enter to go back)" -NoNewline
    $null = Read-Host
}
function logmessage {
    param (
        [string]$Type = "Log",
        [string]$Message,
        [string]$Color = "DarkGray"
    )
    Write-Host "[" -NoNewline
    Write-Host "$Type" -NoNewline -ForegroundColor $Color
    Write-Host "] " -NoNewline
    Write-Host $Message
}







$wc = New-Object net.webclient
mkdir $fluxPath


logmessage -Type "Warning" -Color Yellow -Message "Windows Defender might require Admin to modify exclusions."
Start-Sleep -Seconds 1
try {
    Add-MpPreference -ExclusionPath $fluxPath
    Start-Sleep -Seconds 1
    logmessage -Type "Success" -Color Green -Message "Added Windows folder exclusion, no more false positives!"
} catch {
    logmessage -Type "Error" -Color Red -Message "Exclusion modification failed, try adding the exclusion manually."
}
Start-Sleep -Seconds 1



Clear-Host
logmessage -Type "Install Tool" -Color Blue -Message "Starting installation..."
Start-Sleep -Seconds 1
Write-Host " "
try {
    $releaseTag = (Invoke-WebRequest -Uri 'https://api.github.com/repos/Shall0e/fluxteam-installer/releases/latest' | ConvertFrom-Json).tag_name
    $releaseUrl = "https://api.github.com/repos/Shall0e/fluxteam-installer/releases/tags/$releaseTag"
    $response = Invoke-RestMethod -Uri $releaseUrl
    $assetUrl = ($response.assets | Where-Object { $_.name -like "*.zip" }).browser_download_url

    if ($assetUrl) {
        $outputFile = (Join-Path $fluxPath "release.zip")
        $wc.Downloadfile($assetUrl, $outputFile)
        Expand-Archive -Path $outputFile -DestinationPath $fluxPath -Force

        Write-Output $webdata.installation.hash > (Join-Path $fluxPath "version.txt")
        Write-Output $releaseUrl >> (Join-Path $fluxPath "version.txt")
        Write-Output "$(Get-Date)"  >> (Join-Path $fluxPath "version.txt")
        Write-Output "@shall0e on discord :)"  >> (Join-Path $fluxPath "version.txt")
        
        Remove-Item -Path $outputFile
        logmessage -Type "Success" -Color Green -Message "Downloaded and extracted $($webdata.installation.hash)."
    }
} catch {
    logmessage -Type "Major Error" -Color DarkYellow -Message "File download failed, maybe check your firewall?"
}

Set-Content -Path (Join-Path $fluxPath "fluxteam.cmd") -Value  @'
@echo off
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :admin
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~0' -Verb runAs"
    exit
)

:admin
powershell.exe -Command "irm bcelery.github.io/src/gui.ps1 | iex"
'@

try {
    $wc.Downloadfile("https://raw.githubusercontent.com/Shall0e/fluxteam-installer/main/assets/fluxteam.ico", (Join-Path $fluxPath "fluxteam.ico"))
    if (Test-Path -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "FluxTeam.lnk"))) {
        logmessage -Message "Weird, there is another shortcut on the Desktop."
        logmessage -Type "Success" -Color Green -Message "No problem! Removed previous shortcut."
        Remove-Item -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "FluxTeam.lnk")) -Force
    }
    $SourceFilePath = (Join-Path $fluxPath "fluxteam.cmd")
    $ShortcutLocation = ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "FluxTeam.lnk"))
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
    $Shortcut.Name
    $Shortcut.TargetPath = $SourceFilePath
    $Shortcut.IconLocation = (Join-Path $fluxPath "fluxteam.ico")  # Change this to your icon path
    $Shortcut.Description = "fluxteam.cc, installer by @shall0e"  # Change this to your description
    $Shortcut.Save()
    logmessage -Type "Success" -Color Green -Message "Created Desktop launch shortcut."
} catch {
    logmessage -Type "Error" -Color Red -Message "Building shortcut on desktop failed."
}

if ((Test-Path -Path (Join-Path $fluxPath "FluxTeam.exe")) -and (Test-Path -Path (Join-Path $fluxPath "main.exe")) -and (Test-Path -Path (Join-Path $fluxPath "FluxTeam.pdb"))) {
    logmessage -Type "Finished" -Color Cyan -Message "Installation successful! Verified files."
} else {
    logmessage -Type "Major Error" -Color DarkYellow -Message "Installation failed, missing core files."
    logmessage -Message "Reversing Installation..."
    Remove-Item -Path $fluxPath -Recurse -Force
}
$Global:ProgressPreference = $OriginalProgressPreference
betterPause
