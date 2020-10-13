Function Sql-DataGenerator {
<#

.Author: Chris Dek.

.Synopsis
Data generator, used for successive insert operations for the created table.
.Description
This function will return a layout of the records to be added in the table created in the function below.
The provided record layout is: Code|FirstName|LastName|Address|Status|Male|Date
.Parameter limitation
Number of records to be returned.
.Example
Sql-DataGenerator -limitation <Number_Of_Max_Records>

#>
param(
[Parameter(Mandatory=$true)]
$limitation
)
###
##
#Give name-like appearance for first and last columns..
##
###
[string[]]$namearr1 = @("Jon","Jan","Yen","Yan","Ian","Max","Mac","Mile","Mill","Bo","Bob","Bra","Nic","Nis","Tas","Tess","Kla","Yos","Yosh","Jos","Josh","Geo","Je","Jen","Joe");
[string[]]$namearr2 = @("Hon","Nel","Us","Is","Iz","Cal","El","Ys","Os","Oss","Ds","Son","Ols","Iles","Orge","Ogre","Hau","Heu","An","Ann","Mel","Lie","Li","Azz","Sho","Sha","Kel");
[PSObject[]]$records = @();

###
##
#Rest of the data are randomly created..
##
###
$rndtok = [System.Random]::new();
$location = ''; [int[]] $statusNum = @(25,23,26,1,45,3,54,543,654,11,555); $Male = 0;
for ($i=0; $i -ne $limitation; $i++) {
$initCode = $rndtok.Next(0,$namearr1.Count -1)+($i*30);
$fname ='{0}{1}' -f $namearr1[$rndtok.Next(0,$namearr1.Count -1)],$namearr2[$rndtok.Next(0,$namearr2.Count -1)];
$lname ='{0}{1}' -f $namearr2[$rndtok.Next(0,$namearr2.Count -1)],$namearr1[$rndtok.Next(0,$namearr1.Count -1)];

$addr = "Hd"+$namearr1[$rndtok.Next(0,$namearr1.Count -1)]+"ve"+$namearr2[$rndtok.Next(0,$namearr1.Count -1)]+"at";
$addrnum = $rndtok.Next(0,10)+2;
if ($addr -match 'i') {$location = 'Street.';} else {$location = 'Road';}
$address ='{0} {1} {2}' -f $addrnum,$addr,$location

$stat = $statusNum[$rndtok.Next(0,$statusNum.Count - 1)]+($rndtok.Next(0,300));
if (($rndtok.Next(0,$namearr1.Count -1)) % 2 -eq 0) {$Male = 0;} else {$Male = 1;}
$records += New-Object PSObject -Property @{code=$initCode;firstname=$fname;lastname=$lname;address=$address;status=$stat;male=$Male;date=(Get-Date)};
 }
 return $records;
}

Function Sql-TblCreator {
<#

.Author: Chris Dek.

.Synopsis
The main function that creates a pre-populated table with random data.
.Description
It creates the table (based on Servrer and DB info provided), and adds the generated data to it.
Resolves to default values when null or empty parameters are entered.
.Parameter SrvName
The database server name to connect to (optional - defaults to SQLEXPRESS named srv instance, if applicable.)
.Parameter DBName
The name of the connected database to create the table on.
.Parameter TableName
The name of the table that will be created and populated.
.Parameter limit
The number of generated records/inserts in the specified table (optional - defaults to 10 records)
.Example
Sql-TblCreator -SrvName <DB_Server_Name_Here> -DBName <DB_Instance_Name> -TableName <Table_Name_To_Be_Created_Here> -limit <Number_Of_Max_Records>
.Usage Options
-SrvName '' Sets localhost\SQLEXPRESS as default server
-limit 0 or -limit '' Sets 10 as default limit

#>
[CmdLetBinding()]
param(
[Parameter(Mandatory=$false)]
    [string]
    $SrvName,
[Parameter(Mandatory=$true)]
    [string]
    $DBName,
[Parameter(Mandatory=$true)]
    [string]
    $TableName,
[Parameter(Mandatory=$false)]
    [bigint]
    $limit
)

###
##
#Defaults to local sqlexpress instance..
##
###
if (( ($SrvName -eq $null) -or ($Args.Count -lt 4) ) -or ( ($Args[0] -eq $null) -or ($Args[0] -eq '') )) {$SrvName = $env:COMPUTERNAME+'\SQLEXPRESS';}
###
##
#Defaults to a minimum of 10 records for the DDL statement when not providing any num arguments..
##
###
if ( ($limit -eq $null) -or ($limit -eq 0) ) {$limit = 10;}

$DMLStatement = '';
$DDLStatement = @'
CREATE TABLE [dbo].[{0}](
Code BIGINT PRIMARY KEY NOT NULL,
FirstName NVARCHAR(40) NOT NULL,
LastName NVARCHAR(40) NOT NULL,
Address NVARCHAR(100) NOT NULL,
Status INT NOT NULL,
Male Bit,
TimeOfCreation NVARCHAR(200) NOT NULL)
'@ -f $TableName;

$Srvpath = 'SQLSERVER:\SQL'
Set-Location -Path $Srvpath

#Create Table on SQL Server...
Invoke-Sqlcmd -Query $DDLStatement -Database $DBName -ServerInstance $SrvName -ConnectionTimeout 10

$part1 = "INSERT INTO {0} (Code,FirstName,LastName,Address,Status,Male,TimeOfCreation)`r`n" -f $TableName;
$DMLStatement = $DMLStatement + ($part1);
$outobj = (Sql-DataGenerator -limitation $limit); $i = 0;
$outobj | %{
$part2 = "SELECT {0},'{1}','{2}','{3}',{4},{5},'{6}'`r`n" -f $_.code, $_.firstname, $_.lastname, $_.address, $_.status, $_.male, $_.date;
$part3 = "UNION ALL`r`n";
$i = ($outobj.IndexOf($_));
if ($i -eq $limit - 1) {$part3 = "UNION ALL" -replace "UNION ALL","";}
$DMLStatement = $DMLStatement + ($part2+$part3);
$i++;
 }
#Add the randomized data to the table..
Invoke-Sqlcmd -Query $DMLStatement -Database $DBName -DisableVariables -ServerInstance $SrvName -QueryTimeout ([Int]::MaxValue)
}
Sql-TblCreator -SrvName '' -DBName 'YourDB' -TableName 'RandomTbl' -limit 1000