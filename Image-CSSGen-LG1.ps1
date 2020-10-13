Function Perform-DirClean {
# Use this to cleanup the generated css and html files from any previous runs..
$htmlpath = "$PSScriptRoot\outputfinal.html"; $csspath = "$PSScriptRoot\css\*.css"
if (Test-Path $htmlpath -PathType Leaf) { Remove-Item -Path $htmlpath }; if (Test-Path $csspath) { Remove-Item -Path $csspath }
}

Function Prepare-CssOutput {
<#
Author (All functions below): Chris Dek.
.Synopsis
This function exports a css to be used with the corresponding sprite image.
.Description
The exported css3 file is based on a one-line sprite (including the hover images)
its output form need to be either of vertical or horizontal orientation.
.Parameter orient
The type of sprite accepted (single vertically oriented or horizontally oriented).
.Parameter spritecomplete
The path to the base sprite image to be used in the css export.
.Example
Set function parameter by entering either 'hz' or 'vt' as an orientation parameter.
Run the .ps1 file from the powershell cli to produce the html output.
This is according to the type of sprite image that you are using.

NOTE: All images that will be used in the sprite must be numbered 1..N (N=images in sprite that are not hover images).
#>
param(
[Parameter(Mandatory=$true,Position=0)]
#By default orientation is set to use horizontally placed sprite images
[string]$orient = "hz",
[string]$spritecomplete = (Get-ChildItem -Path "$PSScriptRoot\sprites\*$($orient).png")
)

Perform-DirClean #Cleaning up previously generated files...
$singleimg = [System.Drawing.Image]::FromFile("$PSScriptRoot\images\1.png")
$cssWimg = "{0}px;" -f $singleimg.Width
$cssHimg = "{0}px;" -f $singleimg.Height
[string]$cssmainsprite = "img { object-fit:none; object-position:0 0; width: "+$cssWimg +"height: "+$cssHimg+" }`r`n"; [string[]]$cssimgs = @()
Add-Content -Value $cssmainsprite -Path "$PSScriptRoot\css\sprite_$($orient).css"

$imgCnt = Get-ChildItem -Path "$PSScriptRoot\images\[0-9]*.png" -Name
$imgNames += $imgCnt
$cssimgs += $imgNames | %{ $_ -replace '.png','' }

#Default is horizontal sprite
$direction = ($spritecomplete -clike "*hz*")
$limit = ($imgCnt.Length *2)

for ($y=0; $y -lt $limit; $y++) {

if ($direction) {
$x =($limit/2)
 if ($y -ge $limit/2){
 $cssstr = "`r`nimg.s"+$cssimgs[$y - $x]+":hover{ object-position: "+$($y*$singleimg.Width)*(-1)+"px 0; }"
 Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_hz.css"
 } else {
$cssstr = "img.s"+$cssimgs[$y]+"{ object-position: "+$($y*$singleimg.Width)*(-1)+"px 0; }"
Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_hz.css"
 }

} else {
$x = ($limit/2)
 if ($y -ge $limit/2) {
 $cssstr = "`r`nimg.s"+$cssimgs[$y - $x]+":hover{ object-position: 0 "+$($y*$singleimg.Width)*(-1)+"px; }"
 Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_vt.css"
  } else {
$cssstr = "img.s"+$cssimgs[$y]+"{ object-position: 0 "+$($y*$singleimg.Height)*(-1)+"px; }"
Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_vt.css"
  }
 }
}
$orient
}

Function OutputAs-Html {
<#
.Synopsis
This function utilizes a template to parse the generated css for the sprite. 
.Description
After parsing the sprite css with a template, this script function exports the relevant html
using ConvertTo-Html using the corresponding css under the default executing directory.
.Parameter set
The orientation type set on the previous function (hz or vt).
.Example
This function runs directly and opens up a valid XHTML document complete with the css and hover images.
#>
param (
[Parameter(ValueFromPipeline=$true)]
[string]$set
)
$directory ="$PSScriptRoot\sprites\sprite_final$($set).png"

[string[]]$filename = $directory.Split('\')
$name = $filename[$filename.Count - 1].Split('.')
$direction = $name[0] -replace 'sprite_final', '' -replace 'vt', 'vertical'.toUpper() -replace 'hz', 'horizontal'.toUpper()

$cssinfo = Get-Content "$PSScriptRoot\css\sprite_$($set).css" | ConvertFrom-String -TemplateFile "$PSScriptRoot\csstemplate.txt"

$cssinfo | %{

if ($direction -eq "HORIZONTAL") {
$classname = $_.PSObject.Properties.Value.Split('.')
$classnum =  $classname[1].Split('s')
$closingpart = '" src="{0}" alt="{1}"/>' -f $directory,$classnum[1]

$htmlpre = $($_.PSObject.Properties.Value -replace 'img', '<img ')
$genhtml += "`r`n"+$($htmlpre -replace '.s', 'class="s') +$closingpart

 }
if ($direction -eq "VERTICAL") {
$classname = $_.PSObject.Properties.Value.Split('.')
$classnum =  $classname[1].Split('s')
$closingpart = '" src="{0}" alt="{1}"/></div>' -f $directory,$classnum[1]

$htmlpre = $($_.PSObject.Properties.Value -replace 'img', '<div><img ')
$genhtml += "`r`n"+$($htmlpre -replace '.s', 'class="s') +$closingpart
 } 
}
$htmltitle = "Sprite Creator v1"
$htmlstart = '<div style="font-family:Cambria; font-size:1cm; font-style:oblique;">Your generated sprite is:</div><div style="height:6%"></div>'

$htmlend = '<div style="height:5%"></div><div style="font-family:Roboto; font-size:0.33cm; font-style:oblique;">Base Image Direction: {0}</div>
<div style="font-family:Roboto; font-size:0.33cm; font-style:oblique;">Base Image Directory: {1}</div>' -f $direction,$directory

$htmlayout = $htmlstart+$genhtml+$htmlend
$allhtml = ConvertTo-Html -CssUri "$PSScriptRoot\css\sprite_$($set).css" -Title $htmltitle -Body $htmlayout 
Set-Content -Value $allhtml "$PSScriptRoot\outputfinal.html"

Invoke-Item "$PSScriptRoot\outputfinal.html"
}
Prepare-CssOutput -orient 'hz' | OutputAs-Html