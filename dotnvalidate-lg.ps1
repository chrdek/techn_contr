<#
Author: C.Dek.

# This script includes validation for .net framework installation files (dll check)
# It will download the necessary files if they do not exist and perform a silent install.
# Current version that will be installed is .NET 4.6.2
#>

$dotnetOK = $(Test-Path $env:windir\Microsoft.NET\Framework)
$dotnetOK64 = $(Test-Path $env:windir\Microsoft.NET\Framework64)
$matchesnet = @()

Get-ChildItem "$env:Windir\Microsoft.NET\Framework\*\*.dll" -Recurse | % { $matchesnet += ($_ -match "System.") }
$availNETOK = ( ($dotnetOK -or $dotnetOK64) -and ($matchesnet.Length -ge 1) )

if ($availNETOK) {Write-Host "Dot Net is avail. for ps usage"} else 
{
Write-Host  "Retrieving .NET 4.6+ offline installation files..."
$excfile = "NDP462-KB3151800-x86-x64-AllOS-ENU.exe /passive /norestart"
$fullexecpath = "{0}\Downloads\{1}"-f $env:USERPROFILE,$excfile

$dloader = New-Object System.Net.WebClient
$dloader.DownloadFile("https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe",
                      "$env:USERPROFILE\Downloads\NDP462-KB3151800-x86-x64-AllOS-ENU.exe")

Start-Process $fullexecpath
}