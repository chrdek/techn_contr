<#
Initial settings for VS Projects Nuget Reporting utility
Script environment pre-setup...
#>
$startitems = Get-ChildItem -LiteralPath HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\ | Get-ItemProperty -Name "StartMenuFolder" -ErrorAction SilentlyContinue
$projects = @(); $p = 0;
$startitems | %{ if ($_.StartMenuFolder -ne $null -and $_.StartMenuFolder -ne "") {
$vsprojc = New-Object -TypeName PSObject;
$vsprojc | Add-Member -MemberType NoteProperty -Name "idx" -Value $p
$vsprojc | Add-Member -MemberType NoteProperty -Name "str" -Value ($_.StartMenuFolder | Split-Path -Leaf)
$projects += $vsprojc;
$p++; 
  }
}
Write-Host "Detected VS versions:`r`n";
$projects | %{ $lbl = "[{0}] {1}"-f $projects[[Array]::IndexOf($projects,$_)].idx, $projects[[Array]::IndexOf($projects,$_)].str; Write-Host $($lbl)`r`n; }
$selection = Read-Host "Please Select Visual Studio version for projects..";
$completedir ="{0}\Documents\{1}\Projects" -f $env:USERPROFILE,$projects[$selection].str;

[System.Xml.XmlDocument]$xmlcnf = New-Object System.Xml.XmlDocument;
[PSCustomObject[]]$nugInfo = @([PSCustomObject]@{maindir="";packagesIndir=[PSObject[]]@{packName=""} });
[PSCustomObject[]]$nugInnerInf = @([PSCustomObject]@{packdir="";packageConfigInfo=[PSObject[]]@{name="";version="";value=0;color=""} });

$exportDirTopRpt = '{0}\Documents\JsonTopDirs_Rpt.json' -f $env:USERPROFILE;
$exportDirCfgRpt = '{0}\Documents\JsonCfgFiles_Rpt.json' -f $env:USERPROFILE;
$exportDirCfgGroup = '{0}\Documents\JsonPackagesGroups_Rpt.json' -f $env:USERPROFILE;
$generalConfiguration = '{0}\Documents\Rpt_Settings.json' -f $env:USERPROFILE;

<#Start - Section Selection for configuration file directories..#>

$config = @(); $configval = @();
$getCfg = (Get-Content -LiteralPath $generalConfiguration | Out-String | ConvertFrom-Json)
$getCfg |  %{ $config += $_; $_.PSObject.Properties | %{ $configval += $_.Value; } }

Write-Host "Select the configuration types to process.."`r`n;
for($cnt=0; $cnt -lt $config.Count; $cnt++) {
$cnfnew = $config[$cnt] -replace "@{","" -replace "=}","";
$Cnfstring = "Config File: {0} OPTION [{1}] " -f $cnfnew, $cnt;
Write-Host $Cnfstring;
}
$opt = Read-Host "Select your option for config file(s) processing [0 - $($config.Count - 1)]";
$selectedConfig  = $config[$opt] -replace "@{","" -replace "=}","";

$xpathsett1 = ($configval[$opt].PSObject.Properties | Select-Object Value | %{$_.Value})[0];
$xpathsett2 = ($configval[$opt].PSObject.Properties | Select-Object Value | %{$_.Value})[1];

<#End Section - Set values for configuration dirs..#>

<#Temporary files for exports..#>
$tmp_json1 = '{0}\Documents\export-jsonout.json' -f  $env:USERPROFILE;
$tmp_json2 = '{0}\Documents\export-jsoncleaned.json' -f $env:USERPROFILE;

<#

.DESCRIPTION
    Function used to recursively populate an object containing the subdirectories of *.config files..
.PARAMETER nugetinfoPath
    Main path of the directory to be used
.PARAMETER startValue
    The start value with complete length of subitems in directory

#>
Function Get-InnerNugetInfo {
param([string]$nugetinfoPath,[int]$startValue)
$d = @(); $b = @();
$xmlcnf.Load($nugetinfoPath)

$d += $xmlcnf.SelectNodes($xpathsett1);
$b += $xmlcnf.SelectNodes($xpathsett2);

$newNuget = New-Object -TypeName PSObject;
$newNuget | Add-Member -MemberType NoteProperty -Name "name" -Value $d[$startValue].Value
$newNuget | Add-Member -MemberType NoteProperty -Name "version" -Value $b[$startValue].Value
$newNuget | Add-Member -MemberType NoteProperty -Name "value" -Value ($d[$startValue]).Count
$newNuget | Add-Member -MemberType NoteProperty -Name "color" -Value ""
[PSObject[]] $inputdirs += $newNuget;
if ($startValue -gt 0) {Get-InnerNugetInfo -nugetInfoPath $nugetinfoPath -startValue ($startValue - 1)}
return  $inputdirs;
}

<#
Post-Processing on config directories and nesting of objects..
#>
$completedir | Get-ChildItem -Recurse -File -Filter $selectedConfig | %{

$dirclean = $_.FullName -replace $selectedConfig
#Main obj..
$arrNuget = New-Object -TypeName PSCustomObject
$arrNuget | Add-Member -MemberType NoteProperty -Name "maindir" -Value ""
$arrNuget | Add-Member -MemberType NoteProperty -Name "packagesIndir" -Value ""

$arrNugetCfg = New-Object -TypeName PSCustomObject
$arrNugetCfg | Add-Member -MemberType NoteProperty -Name "packdir" -Value ""
$arrNugetCfg | Add-Member -MemberType NoteProperty -Name "packageConfigInfo" -Value ""
# Nesting starts here..
[PSObject[]]$arrsubnuget = @(@{packName=""});
# Version obj..
[PSObject[]]$arrsubvernuget = @(@{name="";version="";value=0;color=""});
# Main obj..
$arrNuget.packagesIndir = $arrsubnuget;
$arrNugetCfg.packageConfigInfo = $arrsubvernuget;
$nugInfo += $arrNuget;
$nugInnerInf += $arrNugetCfg;
}

<#

.DESCRIPTION
    This function retrieves each top directory under which corresponding 'packages' sub-directory
    resides and produces a relevant json report.
.PARAMETER topdir
    The top level packages directory

#>
Function Report-NugetTopDir {
param([string]$topdir)
$packdir = @();
rm $exportDirTopRpt -ErrorAction SilentlyContinue
$topdir | Get-ChildItem -Directory | %{ $packdir +=($_.FullName | Get-ChildItem -Recurse -Depth 1 -Directory -Include "packages"); }
for ($b=0; $b -lt $packdir.Count; $b++) {
$nugInfo[$b].maindir = $packdir[$b].FullName;
$nugInfo[$b].maindir | Get-ChildItem | %{ $nugInfo[$b].packagesIndir += $_.Name; }
 }
<#Export report of packages base dirs..#>
ConvertTo-Json $nugInfo | Add-Content -LiteralPath $exportDirTopRpt
Start-Process -FilePath $exportDirTopRpt
}

<#

.DESCRIPTION
    This function produces a json report for each .config file and relevant config elements per item.
.PARAMETER subCfgdir
    Directory for sub-folders including .config files

#>
Function Report-NugetConfigDir {
param([string]$subCfgdir)
$packCfg = @();
rm $exportDirCfgRpt -ErrorAction SilentlyContinue
$subCfgdir | Get-ChildItem -Directory | Get-ChildItem -Filter $selectedConfig -Recurse | % { $packCfg += $_.FullName; }
for ($s=0; $s -lt $packCfg.Count; $s++) {
$nugInnerInf[$s].packdir = $packCfg[$s];
$nugInnerInf[$s].packageConfigInfo = Get-InnerNugetInfo -nugetinfoPath ($nugInnerInf[$s].packdir) -startValue $packCfg.Count;
 }
<#Export report of package.config contents per directory (inclusive)#>
ConvertTo-Json $nugInnerInf | Add-Content -LiteralPath $exportDirCfgRpt
Start-Process -FilePath $exportDirCfgRpt
}
Report-NugetTopDir -topdir $completedir

<#

.DESCRIPTION
    Colorization function used for formatting output in treemap js output.
    Used to replicate a heat-map like behavior on the html page.
.PARAMETER inputval
    The numeric color value imported

#>
Function Col-JsonProperties {
param([bigint]$inputval)
$topval = 16711680; #Set initial color range to red..
$addval = [Math]::Floor(0.01Mb + 1291); #Set threshold for range..
$colval;
if ($inputval.ToString().Length -eq 1) {
$colval = $inputval * $addval;
$default = '#{0:X}' -f ($topval - $colval);
$default = $default.Replace("#0F","#F");
 }
if ($inputval.ToString().Length -gt 2) {
$colval = $inputval * $addval;
$default = '#{0:X}' -f ($topval - $colval);
$default = $default.Replace("#0F","#F");
}
if ($inputval.ToString().Length -ge 5) { $default = ('#{0:X}' -f $topval).Replace("#0F","#F"); }
if ( ($inputval.ToString().Length -lt 5) -and ($inputval.ToString().Length -gt 3) ) {
 $colval = $inputval * $addval;
 $default = '#{0:X}' -f ($topval - $colval);
 $default = $default.Replace("#0F","#F");
 }

if ($inputval.ToString().Length -eq 2) {
$colval = $inputval * $addval;
$default = '#{0:X}' -f ($topval - $colval);
$default = $default.Replace("#0F","#F");
 }
 return $default;
}

<#

.DESCRIPTION
    Main function used for exporting the following:
    - Directory config inner file elements json report
    - Grouped config files json report
    - HTML treemap page for all config element instances (per group).

#>
Function Export-NugetCfgStats {
$outputprop = @(); $outCount = @(); $outCol = @();
rm $exportDirCfgGroup -ErrorAction SilentlyContinue
<# Remove temporary files..#>
rm $tmp_json1 -ErrorAction SilentlyContinue
rm $tmp_json2 -ErrorAction SilentlyContinue
Report-NugetConfigDir -subCfgdir $completedir

$packCfg = @();
$completedir | Get-ChildItem -Directory | Get-ChildItem -Filter $selectedConfig -Recurse -Depth 10 | % { $packCfg += $_.FullName; } 

for ($n=0; $n -lt $packCfg.Count; $n++) {
$ObjsOut = $nugInnerInf[$n].packageConfigInfo | Where-Object { $_.Name -ne $null } | Select-Object -Last 1
$ObjsOut | %{$_.name = $_.name +" "+$_.version; $outputprop += $_.name; }

$outputprop | group | %{
$outCount += $_.Count;
$outCol += (Col-JsonProperties -inputval ($_.Count));

foreach ($prop in $ObjsOut) {
 $prop.value = $outCount[[Array]::IndexOf($outputprop,$_.Value)]; 
 $prop.color = $outCol[[Array]::IndexOf($outputprop,$_.Value)];
   }
 ConvertTo-Json $ObjsOut | Add-Content -LiteralPath $tmp_json1
 }
}

<# Check/Create consistent output for json report..#>
Get-Content -LiteralPath $tmp_json1 | %{
$_ -replace "\[","" -replace "\]","" -replace "}", "}," -replace "},,", "},"
} | Set-Content -Path $tmp_json2
<# Export groups of package configuration files.. #>
ConvertTo-Json ($outputprop | group) | Set-Content -LiteralPath $exportDirCfgGroup
Start-Process -FilePath $exportDirCfgGroup

<# Export complete visualization of config stats.. #>
$outputresult = Get-Content -LiteralPath $tmp_json2;
$inSrc = Get-Content -LiteralPath "$env:USERPROFILE\Documents\chart-scripts\inputscript.txt" | %{$_ -replace "\{DATAINPUT\}",$outputresult -replace  '\"\{LABELINPUT\}\"',"'$($selectedConfig) stats'" }
$outbody = @("<div id='container'></div>");
$inSrc | %{ $outbody += $_; }
ConvertTo-Html -Title "Nuget packages stats" -Head @("<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>",
                       "<meta name='viewport' content='width=device-width, initial-scale=1'>",
                       "<link rel='stylesheet' type='text/css' href='.\css\tree-layout.css'>", 
                       "<script src='.\chart-scripts\highcharts.js'></script>",
                       "<script src='.\chart-scripts\treemap.js'></script>") -Body $outbody | Set-Content -LiteralPath ".\NugetStatsReport.html"
Invoke-Item -LiteralPath ".\NugetStatsReport.html"
}
<#
.EXAMPLE
    PS C:\> .\Nuget-Reporter.ps1
    Detected VS versions:

    [0] Visual Studio 2015 

    Please Select Visual Studio version for projects..: 0
    Select the configuration types to process.. 

    Config File: packages.config OPTION [0] 
    Config File: web.config OPTION [1] 
    Config File: web.config OPTION [2] 
    Config File: app.config OPTION [3] 
    Select your option for config file(s) processing [0 - 3]: 0
        <--Relevant JSON & HTML reports are exported and opened directly after entering the PROPER config option..
#>
Export-NugetCfgStats