${Gen-Comments-LG1.ps1} = {function Gen-Comments{param([Parameter(Mandatory=$true)][string]$CodeFileName)Measure-Command {$objOutput=[PSCustomObject]@();$totLOC=(Get-Content -Path ".\$($CodeFileName)").Length;for($i=0;$i -le $totLOC;$i++){$objOutput+=@{"value"=$i;"txt"="" }};$objOutput|ConvertTo-Json -Depth 1|Set-Content -Path ".\comment-lines.json";Write-Host "Created JSON comments file.." -BackgroundColor darkblue -ForegroundColor Yellow;Start-Process -FilePath "notepad.exe" -ArgumentList @(".\comment-lines.json") -WindowStyle Maximized;$fileout=Read-Host "Enter the name of the output js file (with ext.)";$Input=(Get-Content -Path ".\comment-lines.json")|ConvertFrom-Json;$Blank=(Get-Content -Path ".\$($CodeFileName)");$Input|% {$Blank[$_.value-1]+=$_.txt};$Blank|Set-Content -Path ".\$($fileout)"};Start-Process -FilePath "C:\Program Files (x86)\WinMerge\WinMergeU.exe" -ArgumentList @("/f *.js", "/maximize", ".\$($CodeFileName)", ".\$($fileout)")};Gen-Comments -CodeFileName "testfilesample.js"}
