## This cmdlet exports all eventlogs with EventID = 24 from the application event logs to Csv (Mostly WMI events).
Get-EventLog -LogName "Application" -InstanceId 24 | Export-Csv -LiteralPath ".\testeventlog.csv" -NoTypeInformation

## This cmdlet exports all eventlogs with  EventID = 10016 from System event logs created under the "machineName\username" or currently running local account.
Get-EventLog -Log "System" -InstanceId 10016 -UserName "$([System.Environment]::MachineName)*" | Export-Csv -LiteralPath ".\testeventlog2.csv" -NoTypeInformation

## The last cmdlet exports all eventlog error messages created by the "LOCAL SERVICE" or "NETWORK SERVICE" account(s).
 Get-EventLog -Log "System" -EntryType Error -UserName "*SERVICE*" | Export-Csv -LiteralPath ".\testeventlog3.csv" -NoTypeInformation