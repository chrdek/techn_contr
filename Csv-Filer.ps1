<#
.Synopsis
This function is used for generating csv output from a log file that contains
visual studio debug info, and cleans text content for uploading to a log analysis service

.Description
The script might need to be run on-demand or via a scheduled task per modified folder or changed file event 
It exports debug info and creates the appropriate csv formatted output files

NOTE: Generated file with size larger than 64K is transferred to loggly service,
otherwise exported to csv and opened via local text editor
Default target dir is: C:\%APPDATA%\

.Parameter smallsize
Used to identify the output file size either as uploaded or not uploaded

.Example
archive-logs -smallsize <-- Outputs of size smaller than 64k limit
archive-logs            <-- Outputs of size larger or equal than 64k limit

Delimited debug info file format (shown in *.log output file):
-------------------------------------------------------------------------------------
TimeCreated|ComputerName|Problem|Empty|Class|FileName|ExceptionType|ExcepMessage|StackTrace|LOC <-- Header
yyyy-MM-dd HH:mm:ss|ComputerName|ExceptionType|freetext|ComponentName|MethodName|ExceptionText|StackTraceMsg:#lineNumber|#lineNumber <-- Contents
.
.
.
NOTE: You might require additional setup for data cleanup on loggly services site (based on requirements, input data format)

#>
function archive-logs {
param([switch]$smallsize)
$initialpath = "$env:APPDATA\output1.csv"
if (-not(Test-Path -PathType Leaf $initialpath) ) {
break;
}
$cont = (Get-Content -Path $initialpath | Select -Unique)
Set-Content -Value $cont -Path "$env:APPDATA\logs-out.csv"

$csvtemp = Import-csv -Path "$env:APPDATA\logs-out.csv" -Delimiter '|'
$lines = @()
$csvtemp | %{ $lines += [Regex]::Match($_.StackTrace,"(?<=:line )[0-9]{1,}"); }
foreach($rec in $csvtemp) {
$rec.LOC = $lines[[Array]::IndexOf($csvtemp,$rec)];
}

$num = $([System.Random]::new().Next(0,9999));
$finalpath = "$env:APPDATA\csvexcept-$num.csv"
$csvtemp | Export-Csv -Path ".\csvexcept-out.csv" -Delimiter ',' -NoTypeInformation -Encoding Default
Get-Content -Path ".\csvexcept-out.csv" | %{$_ -replace '"',''} | Set-Content -Path $finalpath
Remove-Item -Path ".\csvexcept-out.csv"
Remove-Item -Path "$env:APPDATA\output1.csv"

mkdir -Path "$env:APPDATA\csv-$num" -Force
Move-Item -Path $finalpath -Destination "$env:APPDATA\csv-$num"
$filingpath = "$env:APPDATA\csv-$num\csvexcept-$num.csv"

if ($smallsize) {
$appropsize = ( (Get-Item $filingpath).Length -ge 1KB)
}
$appropsize = ( (Get-Item $filingpath).Length -ge 64KB)
if ( (Test-Path -PathType Leaf $filingpath) -and ($appropsize) ) {
$ulpath = "$env:APPDATA\I386\curl.exe"
$urlserv = "http://logs-01.loggly.com/bulk/ab48807b-4cfb-452e-8371-f9eab2134e32/tag/file_upload"
Start-Process -FilePath $ulpath -ArgumentList "-X POST -T $filingpath $urlserv"
 }else { Start-Process "notepad.exe" -FilePath $filingpath }
}
archive-logs -smallsize