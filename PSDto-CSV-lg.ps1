Function PSDto-CSV {
<#

Author: chris.dek.

.Synopsis
This PS function uses Strings.exe utility to extract binary info from a psd and export relevant content to a csv file.
.Description
PSD text is extracted from layers metadata and font types extracted from actionscript definitions and output as a single csv file.
.Example
Download Strings.exe utility, set the initial PSD file names/path to use on the Invoke-Expression lines. AVOID SPACES IN FILENAMES.
extracted-fonts.txt is included to display currently installed system fonts in the export.
Run the current ps1 file to output the PSD layer info and open the exported csv.

#>
$is64bit = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match "(x64)"
if ($is64bit) {
Invoke-Expression "& $env:USERPROFILE\Downloads\Strings\Strings64.exe -nobanner $env:USERPROFILE\Downloads\Samplefile.psd > $env:USERPROFILE\Downloads\Strings\psd-out.txt"
}
 else {
Invoke-Expression "& $env:USERPROFILE\Downloads\Strings\Strings.exe -nobanner $env:USERPROFILE\Downloads\Samplefile.psd > $env:USERPROFILE\Downloads\Strings\psd-out.txt"
 }
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
(New-Object System.Drawing.Text.InstalledFontCollection).Families | %{ $_ -replace "\[", "" -replace "Name=","" -replace "\]", ""} | Set-Content -Path "$env:USERPROFILE\Documents\extracted-fonts.txt"
$path ="$env:USERPROFILE\Downloads\Strings\psd-out.txt"
$path2 = "$env:USERPROFILE\Documents\extracted-fonts.txt" ; $finaloutput = "$env:USERPROFILE\Documents\all_psdfonts.csv"
$reader = New-Object System.IO.StreamReader($path2); $outfont = @(); $n = 0
while ($reader.Peek() -ne -1) { $outfont += $reader.ReadLine() -replace "FontFamily:",""
$fonts += $outfont[$n].Split("-")
$n++
 }
$text = Get-Content $path | Select-String -AllMatches "<photoshop:LayerText>" |  %{ $_ -replace "<photoshop:LayerText>", "" -replace "</photoshop:LayerText>" ,""}
$fontfam = Get-Content $path | Select-String -AllMatches "/FontType 1" | % { $outvals = $_.LineNumber -3; Get-Content $path | Select -Index $outvals }

[PSObject[]]$fontinfo = @()
for ($of=0; $of -le $outfont.Length -1;  $of++) {
$fontinfo+= New-Object PSObject -Property @{
SysFont      = $outfont[$of]
FontType     = $fontfam[$of]
Text         = $text[$of]
Availability = $($fontfam[$of] -like "*$($fonts[$of])*")
 }
}
$fontinfo | Select SysFont, FontType, Text, Availability | Export-csv -NoTypeInformation -Path $finaloutput
Invoke-Item $finaloutput
}
PSDto-CSV