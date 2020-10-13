<#

Author: Chris Dek.

.Synopsis
 Extraction/Processing of public key contents from a computer's GAC..

.Description
 This script opens all public key tokens from the GAC of a system with .NET installed and 
 also retrievs the corresponding dependent dlls from each assembly manifest on the system.

.Parameter legacyNET
 Change to/from the .NET 4+ or .NET 4 (or less) GAC.

.Example
 Run this file (preferably under administrative powershell cli) and you will get a list of all assembly tokens in your system.
 set the -legacyNET option at the function call of Get-PKTokenWithManifest to get the dll info from older .net installations.

#>
Function Get-PKTokenwithManifest {
#
#Added support for older .NET versions..
param([switch]$legacyNET=$false)

if ($legacyNET) {
#For assemblies prior to .NET 4..
New-PSDrive -Name "GACDrive" -Root "$env:windir\assembly" -PSProvider "FileSystem"
cd GACDrive:

Get-ChildItem -Path .\*.dll -Recurse | %{
([System.Reflection.Assembly]::LoadWithPartialName($_.BaseName).FullName)
([System.Reflection.Assembly]::LoadWithPartialName($_.BaseName).ManifestModule)
[System.Reflection.Assembly]::LoadFile($_.FullName).GetReferencedAssemblies() | Select Name,Version
 }
}

#Support for assemblies of .NET version 4+..
New-PSDrive -Name "DotNetGACDrive" -Root "$env:windir\Microsoft.NET\assembly" -PSProvider "FileSystem"
cd DotNetGACDrive:

Get-ChildItem -Path .\*\*.dll -Recurse | %{
([System.Reflection.Assembly]::LoadWithPartialName($_.BaseName).FullName)
([System.Reflection.Assembly]::LoadWithPartialName($_.BaseName).ManifestModule)
[System.Reflection.Assembly]::LoadFile($_.FullName).GetReferencedAssemblies() | Select Name,Version

}
cd  $env:USERPROFILE\Documents\
 
}
Get-PKTokenwithManifest