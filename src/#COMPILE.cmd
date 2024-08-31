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
cd "C:\Users\Owner\Desktop\Fluxteam Installer\src"
powershell.exe -Command "ps2exe -IconFile .\icon.ico -title 'FluxTeam Installer' -NoError -requireAdmin -inputFile .\compile.ps1 -outputFile .\FTbootstrapper.exe"
pause