<#
.Synopsis
This function runs BCP utility for exporting the corresponding *.fmt file for bulk import utility for a db table

.Description
This runs once per local DB instance, currently supports only local DB. Exports an fmt file with the default settings:

 format nul -f = for generating non-XML file

 -c = for character set information

 -t, = sets the "," table column delimiter for the fmt import file

 -S = specifying a corresponding DB server name that the DB/table resides in

 -T = using DB trusted connection via integrated security for creating the format. file

.Parameter DBServName
The local Sql server instance that the bcp utility is run against

.Parameter DBName
The local database name to connect with

.Parameter TableName
The database table name that will be used by bcp to generate the corresp. formatting file

.Example
PS :\> .\Fmt-Create.ps1
BCP import file generated OK..

The layout of the output file (per table) is shown below:
12.0
7
1       SQLCHAR             0       21      ","      1     ColumnKey                           ""
2       SQLCHAR             0       80      ","      2     ColumnName1                         SQL_Latin1_General_CP1_CI_AS
3       SQLCHAR             0       80      ","      3     ColumnName2                         SQL_Latin1_General_CP1_CI_AS
4       SQLCHAR             0       200     ","      4     Name3                               SQL_Latin1_General_CP1_CI_AS
5       SQLCHAR             0       12      ","      5     Name4                               ""
6       SQLCHAR             0       1       ","      6     Column5                             ""
7       SQLCHAR             0       400     "\r\n"   7     Column6                             SQL_Latin1_General_CP1_CI_AS

#>
Function Get-FmtFile()
{
param(
[string]$DBServName, 
[string]$DBName,
[string]$TableName
)

if (-not(Test-Path "$env:USERPROFILE\Documents\$TableName-layout.fmt")) {
$DBServName = "$([System.Environment]::MachineName)\{0}" -f $DBServName; $DBSel = "{0}.dbo.{1}" -f $DBName, $TableName
$args = @("$DBSel format nul","-c -f $env:USERPROFILE\Documents\$TableName-layout.fmt -t, -S $DBServName -T")
Start-Process -FilePath "bcp" -ArgumentList $args -WindowStyle Hidden
Write-Host "BCP import file generated OK.."
 }
 else {Write-Host "File already exists, run the script with different args.."}
}
Get-FmtFile -DBServName "YourLocalServerInstanceName" -DBName "YourDBName" -TableName "YourTableName"