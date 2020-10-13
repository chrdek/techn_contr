<# 
 # This is an alternative script based on the comment creation function  
 # 
 # that can be used in the same way to generate code snippets. 
 # 
 #> 
Function Create-Snippet() { 
Measure-Command { 
$filename = Read-Host "Enter the name of the json input file"; $fileout = Read-Host "Enter the name of the output js file (with ext.)" 
$Input = (Get-Content -Path ".\$($filename).json") | ConvertFrom-Json 
 
for($l=0; $l -lt 5; $l++) { echo "" >> ".\$($fileout)"} 
 
 $Blank = (Get-Content -Path ".\$($fileout)") 
 $Input | %{ 
  $Blank[$_.value-1] += $_.txt + [System.Environment]::NewLine; 
 } 
$Blank | Set-Content -Path ".\$($fileout)" 
 } 
} 
Create-Snippet