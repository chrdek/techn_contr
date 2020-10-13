<#
.SYNOPSIS
Creation of comments in bulk and comment file merging by using WinMerge.

.DESCRIPTION
This function uses interactively a json file and creates a comment file based on the json input (loc -> corresp. text for line number).
The exported file is used in a merge operation via WinMerge which opens up after files are generated.

.PARAMETER CodeFileName
Specifies the name of the code file to be commented. This should be changed in the file below to the one that the comments will be generated in.

.EXAMPLE
Updated example:
The following example is used for commenting any input code file.
Using the latest code, a file "comment-lines.json" is created based on the original code and is opened in a default text processor to place the comments.

In the sample code below you need to change the output file name "testfilesample.js" to the one that you need the comments merging.
Note: Special characters need to be escaped according to json standard.

PS> .\Gen-Comments.ps1
Created JSON comments file..
Enter the name of the output js file (with ext.): test-comment.js

 #>
Function Gen-Comments() {
param ([Parameter(Mandatory=$true)][string]$CodeFileName)
Measure-Command {
 $objOutput = [PSCustomObject]@();
 $totLOC = (Get-Content -Path ".\$($CodeFileName)").Length
 for ($i=0; $i -le $totLOC; $i++) { $objOutput += @{"value"=$i;"txt"="" }; }
 $objOutput | ConvertTo-Json  -Depth 1 | Set-Content -Path ".\comment-lines.json";
 Write-Host "Created JSON comments file.." -BackgroundColor darkblue -ForegroundColor Yellow
 Start-Process -FilePath "notepad.exe" -ArgumentList @(".\comment-lines.json") -WindowStyle Maximized
 $fileout = Read-Host "Enter the name of the output js file (with ext.)"

$Input = (Get-Content -Path ".\comment-lines.json") | ConvertFrom-Json
 $Blank = (Get-Content -Path ".\$($CodeFileName)")
 $Input | %{
  $Blank[$_.value-1] += $_.txt;
 }
 $Blank | Set-Content -Path ".\$($fileout)"
}
Start-Process -FilePath "C:\Program Files (x86)\WinMerge\WinMergeU.exe" -ArgumentList @("/f *.js", "/maximize", ".\$($CodeFileName)", ".\$($fileout)")
}
Gen-Comments -CodeFileName "testfilesample.js"