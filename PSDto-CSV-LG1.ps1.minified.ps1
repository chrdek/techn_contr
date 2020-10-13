${PSDto-CSV-LG1.ps1} = {function PSDto-CSV{$is64bit=(Get-WmiObject -Class Win32_ComputerSystem).SystemType-match"(x64)";if($is64bit){Invoke-Expression "& $env:USERPROFILE\Downloads\Strings\Strings64.exe -nobanner $env:USERPROFILE\Downloads\Samplefile.psd > $env:USERPROFILE\Downloads\Strings\psd-out.txt"}else{Invoke-Expression "& $env:USERPROFILE\Downloads\Strings\Strings.exe -nobanner $env:USERPROFILE\Downloads\Samplefile.psd > $env:USERPROFILE\Downloads\Strings\psd-out.txt"};[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing");(New-Object System.Drawing.Text.InstalledFontCollection).Families|% {$_-replace"\[",""-replace"Name=",""-replace"\]",""}|Set-Content -Path "$env:USERPROFILE\Documents\extracted-fonts.txt";$path="$env:USERPROFILE\Downloads\Strings\psd-out.txt";$path2="$env:USERPROFILE\Documents\extracted-fonts.txt";$finaloutput="$env:USERPROFILE\Documents\all_psdfonts.csv";$reader=New-Object System.IO.StreamReader ($path2);$outfont=@();$n=0;while($reader.Peek() -ne -1){$outfont+=$reader.ReadLine()-replace"FontFamily:","";$fonts+=$outfont[$n].Split("-");$n++};$text=Get-Content $path|Select-String -AllMatches "<photoshop:LayerText>"|% {$_-replace"<photoshop:LayerText>",""-replace"</photoshop:LayerText>",""};$fontfam=Get-Content $path|Select-String -AllMatches "/FontType 1"|% {$outvals=$_.LineNumber-3;Get-Content $path|Select -Index $outvals};[PSObject[]]$fontinfo=@();for($of=0;$of -le $outfont.Length -1;$of++){$fontinfo+=New-Object PSObject -Property @{
SysFont      = $outfont[$of]
FontType     = $fontfam[$of]
Text         = $text[$of]
Availability = $($fontfam[$of] -like "*$($fonts[$of])*")
 }};$fontinfo|Select SysFont, FontType, Text, Availability|Export-csv -NoTypeInformation -Path $finaloutput;Invoke-Item $finaloutput};PSDto-CSV}
