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





function removeFolder {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        
        [int]$MaxAttempts = 3
    )
    $attempts = 0
    $deleted = $false
    while (-not $deleted -and $attempts -lt $MaxAttempts) {
        try {
            Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction Stop
            $deleted = $true
            logmessage -Type "Success" -Color Green -Message "LocalAppdata folder deleted successfully."
        }
        catch {
            $attempts++
            Start-Sleep -Seconds 1
        }
    }
    if (-not $deleted) {
        logmessage -Type "Error" -Color Red -Message "Failed to delete folder '$FolderPath' after $MaxAttempts attempts."
    }
}

Clear-Host

logmessage -Type "Uninstall" -Color Blue -Message "Starting uninstallation..."
Start-Sleep -Seconds 1
try {
    Stop-Process -Name "main" -Force
    logmessage -Type "Success" -Color Green -Message "Killed injector process."
} catch {
    logmessage -Type "Error" -Color Red -Message "Failed to kill injector process, it might not exist."
}

try {
    Stop-Process -Name "FluxTeam" -Force
    logmessage -Type "Success" -Color Green -Message "Killed GUI process."
} catch {
    logmessage -Type "Error" -Color Red -Message "Failed to kill GUI process, it might not exist."
}

removeFolder -FolderPath $fluxPath -MaxAttempts 5
removeFolder -FolderPath "$($fluxPath)bootstrap" -MaxAttempts 5

logmessage -Type "Warning" -Color Yellow -Message "Windows Defender might require Admin to modify exclusions."
Start-Sleep -Seconds 1
try {
    Remove-MpPreference -ExclusionPath $fluxPath
    Start-Sleep -Seconds 1
    logmessage -Type "Success" -Color Green -Message "Removed Windows folder exclusion."
} catch {
    logmessage -Type "Error" -Color Red -Message "Exclusion modification failed, try removing the exclusion manually."
}

if (Test-Path -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "FluxTeam.lnk"))) {
    Remove-Item -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "FluxTeam.lnk")) -Force
    logmessage -Type "Success" -Color Green -Message "Removed Desktop icon/shortcut."
}

logmessage -Type "Finished" -Color Cyan -Message "All done! Sorry to see you go."

betterPause