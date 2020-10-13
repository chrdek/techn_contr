<#
.SYNOPSIS
Assigning multiple powershell functions on WPF form elements.

.DESCRIPTION
This function is used to wire one or more functions to a click event of a GUI element.
Uses click events associated with functions defined in the same file or an external module.

.PARAMETER window
Required parameter, the loaded form window where click events are added to.

.PARAMETER xmltext
Required parameter, the xaml content that generates the WPF form.

.PARAMETER xpathtext
Optional, text to match the corresponding set of xml elements that call the relevant functions.

.PARAMETER fns
Optional, array of functions to set on the click events (can be either on loaded module or same file).

.PARAMETER module
Option of checking the relevant module where the functions are located.

.EXAMPLE
Functions fn1,fn2,fn4 are declared in the same file and fn3 in an external module which is imported in the cmdline.
The script assigns fn1-fn4 and fn3 functions to the selected UI elements (buttons, checkboxes) and output all error messages in the console and 'application.log' file.

When the script runs, will check the relevant module names and default function definitions and generate the relevant warning messages.
This will nearly always set an error message, provided that the functions used don't match either module or local definitions.

Note: Import-Module is required before checking the relevant modules.
 #>
Function Funct-Setter {

[Cmdletbinding()]
    param
    (
        [Parameter(Mandatory,Position=0)]
        $window,

        [Parameter(Mandatory,Position=1)]
        [xml] $xmltext,

        [Parameter(Mandatory=$false)]
        [string] $xpathtext,

        [Parameter(Mandatory=$false)]
        [PSCustomObject[]] $fns,

        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [string] $module = ""
    )

    Begin {
    # Variable initialization with error checks..

    $i=0;
    $modulefns = ((Get-Module $module -ErrorAction SilentlyContinue).ExportedFunctions.Values | %{$_.Name});

    ForEach ($f in $fns) {
    $modulefnna = ($modulefns | ?{$_-ilike "$f*"}).Length -ge 1;
    $fnempty = (Get-Command $f -CommandType Function -ErrorAction SilentlyContinue).Definition -eq $null;

    if ($fnempty) {
    Write-Host -BackgroundColor Black -ForegroundColor Yellow "[FN:] - $($f) Function Definition Unavailable.."
    Write-Error -Message "$($f) Function Definition Unavailable.." -Category InvalidData -ErrorVariable 'invalidata'; $invalidata | Out-File -FilePath ".\application.log" -Append
       }

     if (-not$modulefnna) {
      Write-Host -BackgroundColor Black -ForegroundColor Yellow "[MODULE FN:] - $($f) Function Unavailable, module $($module)"
      Write-Error -Message "$($f) Function unavailable, module $($module)" -Category InvalidData -ErrorVariable 'invalidata'; $invalidata | Out-File -FilePath ".\application.log" -Append
      }

     }
    }

    Process {
    # Setup of events..

    Try {

 $xmltext.SelectNodes("//*[@Name]") | ?{$_.Name -like "*$($xpathtext)*" } | %{

     $window.FindName($_.Name).add_Click([Windows.RoutedEventHandler]$fns[$i]);
     $i++;
      } -ErrorAction Stop -ErrorVariable 'exception'
    }
    Catch {
    Write-Error -Message "Error during event setup.. $($exception.Message)" -Category InvalidOperation -ErrorVariable 'invalidop'; $invalidop | Out-File -FilePath ".\application.log" -Append
     }
    }

    End {
    # Finish of functions setup. Cleanup of variables, setup..
    
    Write-Host "$($error.Count) out of $($error.Capacity) errors purged.."
    $error.Clear();
    }
}