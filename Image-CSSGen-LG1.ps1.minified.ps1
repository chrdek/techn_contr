${Image-CSSGen-LG1.ps1} = {function Perform-DirClean{$htmlpath="$PSScriptRoot\outputfinal.html";$csspath="$PSScriptRoot\css\*.css";if(Test-Path $htmlpath -PathType Leaf){Remove-Item -Path $htmlpath};if(Test-Path $csspath){Remove-Item -Path $csspath}};function Prepare-CssOutput{param([Parameter(Mandatory=$true,Position=0)][string]$orient,[string]$spritecomplete)Perform-DirClean;$singleimg=[System.Drawing.Image]::FromFile("$PSScriptRoot\images\1.png");$cssWimg="{0}px;"-f$singleimg.Width;$cssHimg="{0}px;"-f$singleimg.Height;[string]$cssmainsprite="img { object-fit:none; object-position:0 0; width: "+$cssWimg+"height: "+$cssHimg+" }`r`n";[string[]]$cssimgs=@();Add-Content -Value $cssmainsprite -Path "$PSScriptRoot\css\sprite_$($orient).css";$imgCnt=Get-ChildItem -Path "$PSScriptRoot\images\[0-9]*.png" -Name;$imgNames+=$imgCnt;$cssimgs+=$imgNames|% {$_-replace'.png',''};$direction=($spritecomplete-clike"*hz*");$limit=($imgCnt.Length*2);for($y=0;$y -lt $limit;$y++){if($direction){$x=($limit/2);if($y-ge$limit/2){$cssstr="`r`nimg.s"+$cssimgs[$y - $x]+":hover{ object-position: "+$($y*$singleimg.Width)*(-1)+"px 0; }";Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_hz.css"}else{$cssstr="img.s"+$cssimgs[$y]+"{ object-position: "+$($y*$singleimg.Width)*(-1)+"px 0; }";Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_hz.css"}}else{$x=($limit/2);if($y-ge$limit/2){$cssstr="`r`nimg.s"+$cssimgs[$y - $x]+":hover{ object-position: 0 "+$($y*$singleimg.Width)*(-1)+"px; }";Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_vt.css"}else{$cssstr="img.s"+$cssimgs[$y]+"{ object-position: 0 "+$($y*$singleimg.Height)*(-1)+"px; }";Add-Content -Value $cssstr -Path "$PSScriptRoot\css\sprite_vt.css"}}};$orient};function OutputAs-Html{param([Parameter(ValueFromPipeline=$true)][string]$set)$directory="$PSScriptRoot\sprites\sprite_final$($set).png";[string[]]$filename=$directory.Split('\');$name=$filename[$filename.Count - 1].Split('.');$direction=$name[0]-replace'sprite_final',''-replace'vt','vertical'.toUpper()-replace'hz','horizontal'.toUpper();$cssinfo=Get-Content "$PSScriptRoot\css\sprite_$($set).css"|ConvertFrom-String -TemplateFile "$PSScriptRoot\csstemplate.txt";$cssinfo|% {if($direction-eq"HORIZONTAL"){$classname=$_.PSObject.Properties.Value.Split('.');$classnum=$classname[1].Split('s');$closingpart='" src="{0}" alt="{1}"/>'-f$directory,$classnum[1];$htmlpre=$($_.PSObject.Properties.Value-replace'img','<img ');$genhtml+="`r`n"+$($htmlpre-replace'.s','class="s')+$closingpart};if($direction-eq"VERTICAL"){$classname=$_.PSObject.Properties.Value.Split('.');$classnum=$classname[1].Split('s');$closingpart='" src="{0}" alt="{1}"/></div>'-f$directory,$classnum[1];$htmlpre=$($_.PSObject.Properties.Value-replace'img','<div><img ');$genhtml+="`r`n"+$($htmlpre-replace'.s','class="s')+$closingpart}};$htmltitle="Sprite Creator v1";$htmlstart='<div style="font-family:Cambria; font-size:1cm; font-style:oblique;">Your generated sprite is:</div><div style="height:6%"></div>';$htmlend='<div style="height:5%"></div><div style="font-family:Roboto; font-size:0.33cm; font-style:oblique;">Base Image Direction: {0}</div>
<div style="font-family:Roboto; font-size:0.33cm; font-style:oblique;">Base Image Directory: {1}</div>'-f$direction,$directory;$htmlayout=$htmlstart+$genhtml+$htmlend;$allhtml=ConvertTo-Html -CssUri "$PSScriptRoot\css\sprite_$($set).css" -Title $htmltitle -Body $htmlayout;Set-Content -Value $allhtml "$PSScriptRoot\outputfinal.html";Invoke-Item "$PSScriptRoot\outputfinal.html"};Prepare-CssOutput -orient 'hz'|OutputAs-Html}