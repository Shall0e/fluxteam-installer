$runningOnline = $false

$ErrorActionPreference = 'SilentlyContinue'
$Global:ProgressPreference = 'SilentlyContinue'
$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$fluxPath = (Join-Path $localAppData "FluxTeam")
$rbxversion = (Invoke-WebRequest -UserAgent "WEAO-3PService" -Method Get -Uri 'https://weao.xyz/api/versions/current' | ConvertFrom-Json).Windows
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

Set-PSReadLineOption -BackgroundColor Blue
$host.UI.RawUI.WindowTitle = "FluxTeam Installer"
Add-Type -TypeDefinition @'
    using System;
    using System.Runtime.InteropServices;
    public class PInvoke {
        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern IntPtr GetStdHandle(int nStdHandle);
        [DllImport("kernel32.dll", CharSet=CharSet.Auto, SetLastError=true)]
        public static extern bool GetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFO_EX lpConsoleCurrentFontEx);
        [DllImport("kernel32.dll", CharSet=CharSet.Auto, SetLastError=true)]
        public static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFO_EX lpConsoleCurrentFontEx);
        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Auto)]
        public struct COORD {
            public short X;
            public short Y;
            public COORD(short x, short y) {
                X = x;
                Y = y;
            }
        }
        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Auto)]
        public struct CONSOLE_FONT_INFO_EX {
            public int cbSize;
            public uint nFont;
            public COORD dwFontSize;
            public int FontFamily;
            public int FontWeight;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst=0x20)]
            public string FaceName;
        }
    }
'@


function SetConsoleFontSize {
    param (
        [int]$FontSize
    )
    $StdOutHandle = [PInvoke]::GetStdHandle(-11)
    $ConsoleFontInfo = New-Object PInvoke+CONSOLE_FONT_INFO_EX
    $ConsoleFontInfo.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($ConsoleFontInfo)
    $ConsoleFontInfo.dwFontSize = New-Object PInvoke+COORD -ArgumentList 0, $FontSize
    [PInvoke]::SetCurrentConsoleFontEx($StdOutHandle, $false, [ref]$ConsoleFontInfo)
}
$width = 80
$height = 40
$bufferSize = New-Object System.Management.Automation.Host.Size($width, 3000)  # Adjust 3000 as needed
$host.ui.rawui.BufferSize = $bufferSize
$windowSize = New-Object System.Management.Automation.Host.Size($width, $height)
$host.ui.rawui.WindowSize = $windowSize
SetConsoleFontSize -FontSize 18
$console = [Console]::OpenStandardOutput()

Clear-Host



function neofetch {
    Clear-Host
    $nothing = SetConsoleFontSize -FontSize 16
    $nothing = $null
    $null = $nothing
    Write-Host ' '
    Write-HostCenter -ForegroundColor 'Blue' -Message '           X$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$x  X$$$$$$$$$$$$$$$$$$$$$$$$$$$&x'
    Write-HostCenter -ForegroundColor 'Blue' -Message '          xx.............................x$&xXx..........................:$$X'
    Write-HostCenter -ForegroundColor 'Blue' -Message '          &............................:$$xx$:..........................;$$x '
    Write-HostCenter -ForegroundColor 'Blue' -Message '         x:...........................;$$xxx..........................:X$&   '
    Write-HostCenter -ForegroundColor 'Blue' -Message '        Xx.........;+x++x++xx++x++++x$$x xxx+xx+;+xx:.........;++x++x$$$x    '
    Write-HostCenter -ForegroundColor 'Blue' -Message '       x$..........$Xxxxxxxxxxxxxxxxxx    xxxxxxxxxx.........:$&xxxxxxx      '
    Write-HostCenter -ForegroundColor 'Blue' -Message '       X;.........x$$x+++++++++++x$$x             x:.........$$x             '
    Write-HostCenter -ForegroundColor 'Blue' -Message '      xx.........:$$:..........:$$$x             x;.........x$$              '
    Write-HostCenter -ForegroundColor 'Blue' -Message '      X.........:$:..........:$$$x              xX.........:$$x              '
    Write-HostCenter -ForegroundColor 'Blue' -Message '     $;.....................X$$x                $..........$$X               '
    Write-HostCenter -ForegroundColor 'Blue' -Message '    xx.........:xxxxxxxxxx$$$x                 $;.........+$$                '
    Write-HostCenter -ForegroundColor 'Blue' -Message '    $:........:$$xxxxxxxxxxx                  xx.........:$$x                '
    Write-HostCenter -ForegroundColor 'Blue' -Message '   X:.........x$X                             $:.........$$x                 '
    Write-HostCenter -ForegroundColor 'Blue' -Message '  xx.........;$&                             X;.........;$$                  '
    Write-HostCenter -ForegroundColor 'Blue' -Message '  &:.........$$x                            xx.........:$$                   '
    Write-HostCenter -ForegroundColor 'Blue' -Message ' x:.........x$$                             $:.........X$x                   '
    Write-HostCenter -ForegroundColor 'Blue' -Message 'x$&&&&&&$&&$$$                             x&&&&&$$$$$$$$                    '
    Write-Host ' '

    $neoversion = (Invoke-WebRequest -UserAgent "WEAO-3PService" -Method Get -Uri 'https://weao.xyz/api/versions/current' | ConvertFrom-Json).WindowsDate
    Write-HostCenter -ForegroundColor 'White' -Message "last Roblox update: $neoversion"
    Write-HostCenter -ForegroundColor 'White' -Message "newest Roblox version: $rbxversion"

    Write-Host ' '
    Write-HostCenter -ForegroundColor 'Yellow' -Message "Credits:"
    Write-HostCenter -ForegroundColor 'Yellow' -Message "fluxteam.cc  :  FluxTeam Executor"
    Write-HostCenter -ForegroundColor 'Yellow' -Message "@shall0e  :  Updater Creator"
    Write-HostCenter -ForegroundColor 'Yellow' -Message "WEAO.xyz Team  :  WEAO API"
    Write-HostCenter -ForegroundColor 'Yellow' -Message "fuck celery"
    Write-Host ' '
    Write-HostCenter -ForegroundColor 'Blue' -Message "https://discord.gg/fluxus"
    Write-Host ' '
    betterPause
}

Remove-Item -Path (Join-Path ([Environment]::GetFolderPath('MyDocuments')) "fluxteam.cmd") -Force
function Write-HostCenter { param([string]$Message,[string]$ForegroundColor="White") Write-Host -ForegroundColor $ForegroundColor ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) }




for (;;) {
    $installationdata = ((Get-Content -Path (Join-Path $fluxPath "version.txt")) -split "\n")
    $bufferSize = New-Object System.Management.Automation.Host.Size($width, 3000)  # Adjust 3000 as needed
    $host.ui.rawui.BufferSize = $bufferSize
    $nothing = SetConsoleFontSize -FontSize 18


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

    Write-Host "[" -NoNewline
    Write-Host "Broadcast" -NoNewline -ForegroundColor Blue
    Write-Host "] " -NoNewline
    Write-Host $webdata.broadcast.message -ForegroundColor $webdata.broadcast.color
    Write-Host " "
    Write-Host " "
    

    # INSTALL MENU
    if ($installed) {
        Write-Host '[1] - Install FluxTeam' -ForegroundColor Red
        Write-Host ' | ' -NoNewline; Write-Host "[Error] : FluxTeam is already installed!" -ForegroundColor Yellow
    } else {
        Write-Host '[1] - Install FluxTeam'
        Write-Host ' | ' -NoNewline; Write-Host "[Roblox Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$rbxversion" -ForegroundColor Green
        if ($working) {
            Write-Host ' | ' -NoNewline; Write-Host "[Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$($webdata.installation.hash)" -ForegroundColor Green
            Write-Host ' | ' -NoNewline; Write-Host "[Status] : " -ForegroundColor Yellow -NoNewline; Write-Host "Working" -ForegroundColor Green
        }   else {
            Write-Host ' | ' -NoNewline; Write-Host "[Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$($webdata.installation.hash)" -ForegroundColor Red
            Write-Host ' | ' -NoNewline; Write-Host "[Status] : " -ForegroundColor Yellow -NoNewline; Write-Host "Patched" -ForegroundColor Red
        }
    }

    Write-Host ' '
    Write-Host '-----------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ' '

    if ($installed) {
        Write-Host '[2] - Uninstall FluxTeam'
        Write-Host ' | ' -NoNewline; Write-Host "[Path] : $fluxPath" -ForegroundColor Yellow
        Write-Host ' | ' -NoNewline; Write-Host "[Installed Version] : $($installationdata[0])" -ForegroundColor Yellow
        Write-Host ' | ' -NoNewline; Write-Host "[Install Date] : $($installationdata[2])" -ForegroundColor Yellow
        if ((!$working) -or $outdated) {
            Write-Host ' | ' -NoNewline; Write-Host "[Status] : " -ForegroundColor Yellow -NoNewline; Write-Host "Patched" -ForegroundColor Red
        } else {
            Write-Host ' | ' -NoNewline; Write-Host "[Status] : " -ForegroundColor Yellow -NoNewline; Write-Host "Working" -ForegroundColor Green
        }
    } else {
        Write-Host '[2] - Uninstall FluxTeam' -ForegroundColor Red
        Write-Host ' | ' -NoNewline; Write-Host "[Error] : FluxTeam is not installed!" -ForegroundColor Yellow
    }

    Write-Host ' '
    Write-Host '-----------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ' '

    if ($installed) {
        if ($outdated) {
            Write-Host '[3] - Update FluxTeam' -ForegroundColor Cyan
            Write-Host ' | ' -NoNewline; Write-Host "[Message] : " -ForegroundColor Yellow -NoNewline; Write-Host "New update avalible!" -ForegroundColor blue
            Write-Host ' | ' -NoNewline; Write-Host "[Current Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$($installationdata[0])" -ForegroundColor Red
            Write-Host ' | ' -NoNewline; Write-Host "[Latest Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$($webdata.installation.hash)" -ForegroundColor Green
        } else {
            Write-Host '[3] - Update FluxTeam' -ForegroundColor Red
            Write-Host ' | ' -NoNewline; Write-Host "[Error] : Your version is up to date!" -ForegroundColor Yellow
            Write-Host ' | ' -NoNewline; Write-Host "[Current Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$($installationdata[0])" -ForegroundColor Green
            Write-Host ' | ' -NoNewline; Write-Host "[Latest Version] : " -ForegroundColor Yellow -NoNewline; Write-Host "$($webdata.installation.hash)" -ForegroundColor Green
        }
        if ($working) {
            Write-Host ' | ' -NoNewline; Write-Host "[Status] : " -ForegroundColor Yellow -NoNewline; Write-Host "Working" -ForegroundColor Green
        } else {
            Write-Host ' | ' -NoNewline; Write-Host "[Status] : " -ForegroundColor Yellow -NoNewline; Write-Host "Patched" -ForegroundColor Red
        }
    } else {
        Write-Host '[3] - Update FluxTeam' -ForegroundColor Red
        Write-Host ' | ' -NoNewline; Write-Host "[Error] : FluxTeam is not installed!" -ForegroundColor Yellow
    }

    Write-Host ' '
    Write-Host '-----------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ' '

    Write-Host '[4] - Neofetch'
    Write-Host ' | ' -NoNewline; Write-Host "[Message] : Quick info on Roblox Updates" -ForegroundColor Yellow

    Write-Host ' '
    Write-Host '-----------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ' '

    Write-Host -ForegroundColor Magenta "Selection > " -NoNewline
    $selection = (Read-Host)
    if ($selection -eq 1) {
        if (-not $installed) {
            powershellEmulator -On c -Path "modules\install.ps1"
        }
    } elseif ($selection -eq 2) {
        if ($installed) {
            powershellEmulator -On $runningOnline -Path "modules\uninstall.ps1"
        }
    } elseif ($selection -eq 3) {
        if ($installed -and $outdated) {
            Clear-Host
            powershellEmulator -On $runningOnline -Path "modules\update.ps1"
            betterPause
        }
    } elseif ($selection -eq 4) {
        neofetch
    }
    Clear-Host
}
Exit-PSSession
