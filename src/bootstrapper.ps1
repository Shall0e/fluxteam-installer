$runningOnline = $true

$ErrorActionPreference = 'SilentlyContinue'
$Global:ProgressPreference = 'SilentlyContinue'
$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$fluxPath = (Join-Path $localAppData "FluxTeam")
$rbxversion = (Invoke-WebRequest -UserAgent "WEAO-3PService" -Method Get -Uri 'https://whatexpsare.online/api/versions/current' | ConvertFrom-Json).Windows
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$webdata = invoke-webrequest -URI "https://raw.githubusercontent.com/Shall0e/fluxteam-installer/main/data.json" | ConvertFrom-Json
$installationdata = ((Get-Content -Path (Join-Path $fluxPath "version.txt")) -split "\n")
$OriginalProgressPreference = $Global:ProgressPreference
[System.Console]::BackgroundColor = 'Black'

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
        powershell.exe -File (Join-Path $scriptDir $Path)
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





if (Test-Path $fluxPath -PathType Container) {
    $installed = $true
} else {
    $installed = $false
}
if ($webdata.installation.hash -eq $rbxversion) {
    $working = $true
} else {
    $working = $false
}
if ($webdata.installation.hash -eq $installationdata[0]) {
    $outdated = $false
} else {
    $outdated = $true
}

Write-Host ' '
Write-Host -ForegroundColor DarkBlue '           X$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$x  X$$$$$$$$$$$$$$$$$$$$$$$$$$$&x'
Write-Host -ForegroundColor Blue '          xx.............................x$&xXx..........................:$$X'
Write-Host -ForegroundColor Blue '          &............................:$$xx$:..........................;$$x '
Write-Host -ForegroundColor Blue '         x:...........................;$$xxx..........................:X$&   '
Write-Host -ForegroundColor Blue '        Xx.........;+x++x++xx++x++++x$$x xxx+xx+;+xx:.........;++x++x$$$x    '
Write-Host -ForegroundColor Blue '       x$..........$Xxxxxxxxxxxxxxxxxx    xxxxxxxxxx.........:$&xxxxxxx      '
Write-Host -ForegroundColor Blue '       X;.........x$$x+++++++++++x$$x             x:.........$$x             '
Write-Host -ForegroundColor Blue '      xx.........:$$:..........:$$$x             x;.........x$$              '
Write-Host -ForegroundColor Blue '      X.........:$:..........:$$$x              xX.........:$$x              '
Write-Host -ForegroundColor Blue '     $;.....................X$$x                $..........$$X               '
Write-Host -ForegroundColor Blue '    xx.........:xxxxxxxxxx$$$x                 $;.........+$$                '
Write-Host -ForegroundColor Blue '    $:........:$$xxxxxxxxxxx                  xx.........:$$x                '
Write-Host -ForegroundColor Blue '   X:.........x$X                             $:.........$$x                 '
Write-Host -ForegroundColor Blue '  xx.........;$&                             X;.........;$$                  '
Write-Host -ForegroundColor Blue '  &:.........$$x                            xx.........:$$                   '
Write-Host -ForegroundColor Blue ' x:.........x$$                             $:.........X$x                   '
Write-Host -ForegroundColor DarkBlue 'x$&&&&&&$&&$$$                             x&&&&&$$$$$$$$                    '
Write-Host ' '
Write-Host '---------------------------------------------------------------------------' -ForegroundColor DarkGray
Write-Host ' '
Start-Sleep -Milliseconds 500

$IsExcluded = $DefenderPreferences.ExclusionPath -contains $fluxPath -or
              $DefenderPreferences.ExclusionProcess -contains $fluxPath -or
              $DefenderPreferences.ExclusionExtension -contains $fluxPath

if ((Get-Process -Name "FluxTeam") -or (Get-Process -Name "main")) {
    logmessage -Type "Error" -Color Red -Message "There seems to be another instance running."
    Start-Sleep -Milliseconds 2000
    logmessage -Message "Closing extra instances."
    try {
        Stop-Process -Name "FluxTeam" -Force
        Stop-Process -Name "Main" -Force
    } catch {
        logmessage -Type "Error" -Color Red -Message "There was an issue killing other instance."
    }
}
if ($IsExcluded) {
    logmessage -Type "FluxTeam" -Color Magenta -Message "Checking for updates..."
    Start-Sleep -Milliseconds 2000
    if (-not $installed) {
        logmessage -Type "FluxTeam" -Color Magenta -Message "FluxTeam is not installed."
        powershellEmulator -On $runningOnline -Path "modules\install.ps1"
    }
    if ($outdated -and $installed) {
        Start-Sleep -Milliseconds 2000
        powershellEmulator -On $runningOnline -Path "modules\update.ps1"
    }
    logmessage -Type "FluxTeam" -Color Magenta -Message "Starting FluxTeam..."
    Start-Sleep -Milliseconds 500
    if (Test-Path -Path (Join-Path $fluxPath "FluxTeam.exe")) {
        Start-Process -FilePath (Join-Path $fluxPath "FluxTeam.exe")
    } else {
        logmessage -Type "Major Error" -Color DarkYellow -Message "FluxTeam executable not located, try disabling your antivirus and reinstalling."
        Start-Sleep -Milliseconds 1000
    }
} else {
    logmessage -Type "Major Error" -Color DarkYellow -Message "No Defender exclusion path, FluxTeam will not open."
    logmessage -Message "To set an exclusion path in Windows Defender:"
    logmessage -Message "1. Head to Windows Security on your search menu."
    logmessage -Message '2. Go to "Virus & Threat Protection".'
    logmessage -Message '3. Scroll down to "Add or remove exclusions".'
    logmessage -Message '4. Add an exclusion with the "Folder" type.'
    logmessage -Message ('5. Select the directory"',$fluxPath,'".')
    Start-Sleep -Milliseconds 1000
    logmessage -Type "FluxTeam" -Color Magenta -Message "Auto closing window in 20 seconds..."
    Start-Sleep -Milliseconds 20000
}
Start-Sleep -Milliseconds 1000
exit