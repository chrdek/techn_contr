<#
.SYNOPSIS
    This powershell script uses the strings (exe) text converter to extract and group content from a visual studio project DB file (Pdb).

.DESCRIPTION
    Usage of this script requires that you have the strings.exe utility on your system. Once run, a text file with 
    all  directories and relevant pdb files will be opened. Select the line of the file which you want to extract information for and enter it once prompted on the powershell 
    command window. You can find the bin. converted script in .\pdbtext.out and the pdb directories (and files) in file .\all-pdbs.export

.EXAMPLE
    PS C:\> .\Pdb-Exporter.ps1
                                                                               <-- A text file opens up to select the line of the directory of your file..
Enter the line number of the file to process in the list of PDB files..: 28    <-- You need to enter the line from your text file that corresponds to the  pdb file here..
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 15
Ticks             : 157584
TotalDays         : 1.82388888888889E-07
TotalHours        : 4.37733333333333E-06
TotalMinutes      : 0.00026264
TotalSeconds      : 0.0157584
TotalMilliseconds : 15.7584

Id      : 22----
Handles : --
CPU     : 0
SI      : 1
Name    : strings
#>
# Directories for VStudio Projects and Strings utility initialization.. Change directories according to your installations.
$initializeDir = "{0}\Documents\Visual Studio 2015\Projects\" -f $env:USERPROFILE;
$excUtil = "{0}\Downloads\Strings\strings.exe" -f $env:USERPROFILE;
$exewd = "{0}\Downloads\Strings\" -f $env:USERPROFILE;

$exportedPdbs = "{0}\Documents\all-pdbs.export" -f $env:USERPROFILE;
$exporteddata = "{0}\Documents\pdbtext.out" -f $env:USERPROFILE;

$basedir = "{0}\Documents\" -f $env:USERPROFILE;
# Five different templates for pdb information extraction are setup here..
$csfiles = "$($basedir)sample_CSSolfiles.txt";
$nspaces = "$($basedir)sample_NSusings.txt";
$constrInst = "$($basedir)sample_Constr.txt";
$delInst = "$($basedir)sample_deleg.txt"
$BPointProgr = "$($basedir)sample_breakp.txt"

# Data extraction starts here..
Get-ChildItem -LiteralPath $initializeDir -Recurse -File | Where-Object { $_.FullName -match ".pdb" } | %{ $_.FUllName } | Set-Content -LiteralPath $exportedPdbs
Start-Process "notepad.exe" -ArgumentList $exportedPdbs
$lineNumInput = Read-Host "Enter the line number of the file to process in the list of PDB files.."
$selpdb = (Get-Content $exportedPdbs | Select-String -AllMatches ".pdb" | Select -Index ($lineNumInput - 1));
$options = "-nobanner `"$($selpdb)`" > $($exporteddata)"
Measure-Command { Start-Process $env:ComSpec -WorkingDirectory $exewd -ArgumentList "/C $($excUtil) $options" -WindowStyle Hidden }
Write-Host ""`r`n;
[System.Diagnostics.Process]::Start.Invoke($excUtil,"$options");

# Pdb file transformation starts here..
Get-Content -LiteralPath $exporteddata | ConvertFrom-String -TemplateFile $csfiles | Format-Table
Get-Content -LiteralPath $exporteddata | ConvertFrom-String -TemplateFile $nspaces | Format-Table
Get-Content -LiteralPath $exporteddata | ConvertFrom-String -TemplateFile $constrInst | Format-Table
Get-Content -LiteralPath $exporteddata | ConvertFrom-String -TemplateFile $delInst | Format-Table
Get-Content -LiteralPath $exporteddata | ConvertFrom-String -TemplateFile $BPointProgr | Format-Table