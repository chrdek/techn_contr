<#
.SYNOPSIS
Bulk deletion function with partial and exact filename matching to create batches of files.

.DESCRIPTION
This function provides bulk deletion capability with confirmation for many files.

.PARAMETER basefld
Required, the root directory folder name to start the recursive search.

.PARAMETER name
Required, the partial or whole name match per folder search.

.PARAMETER extension
Set as an option, defaults to 'txt' if not set in params. Extension for file filtering.

.PARAMETER usePartial
Switch for usage of partial matches in filename(s).Ommiting this results in exact name search.

.PARAMETER useFile
Switch for selecting files only or folders only search.

.EXAMPLE
Del-Many -basefld ".\*.mps" -name "Name2" -extension "txt" -usePartial -useFile

This sample searches recursively from the running directory and deletes all 
files with partial matches of "Name2" and with extensions "txt" in their filename.
Using  "mps" in base folder will not affect the function's result.
NOTE: Use -basefld with ".\" only, extensions are truncated from the root folder name.


Del-Many -basefld ".\" -name "Name2" -extension "pdf" -usePartial

This line searches for directories that include pdf files with "Name2" in their filename and list 
them for deletion. Ommiting the -useFile switch results in creating a directory list instead.
#>
Function Del-Many {
param(
[Parameter(Mandatory=$true)]
[AllowNull()]
[AllowEmptystring()]
[string]$basefld,
[Parameter(Mandatory=$true)]
[AllowNull()]
[AllowEmptyString()]
[string]$name,
[Parameter(Mandatory=$false)]
[string]$extension,
[Parameter(Mandatory=$false)]
[switch]$usePartial,
[Parameter(Mandatory=$false)]
[switch]$useFile
)
$tobeDel = @();$outpufiles = @(); $basefld = $basefld -replace ".\*.[a-zA-Z]+",".\" -replace "..", "."

if (($basefld -eq $null) -or ($basefld -eq '')) { $basefld = '.\' }
if (($extension -eq $null) -or ($extension -eq '')) { $extension = 'txt' }
$extstr = $extension; $extension ='*.{0}' -f $extension

##Load either directories or files from base dir..
if (-not $useFile) {
$dirCont = (Get-ChildItem $basefld -Recurse -Directory)
} else {
$dirCont = (Get-ChildItem $basefld$extension -Recurse)
}
##Set a partial name or exact matches for directory or file names
if($usePartial) {
$dirCont | ?{$_.Name -match $($name)} | Select Name,LastWriteTime,FullName | %{ $tobeDel += $_ };
} else {
$dirCont | ?{$_.Name -eq $($name)+".$extstr"} | Select Name,LastWriteTime,FullName | %{ $tobeDel += $_ };
}
Write-Host ""`r`n
Write-Host "Similar file names to delete:".toUpper();
$tobeDel | Format-Table -AutoSize
$confirmdel = Read-Host "Enter confirmation for deletion Y/N"

if ($confirmdel -eq "Y") {
$tobeDel |  %{rm $_.FullName; Write-Host $_.FullName"- Deleted..."}
 } else {Write-Host "Exiting..";continue}
}