function Get-LatestChocoPackage {
<#
 .SYNOPSIS
    Get the latest version of one or more packages from the Chocolatey community repository.
 .EXAMPLE
PS C:\Chocotemp> Get-LatestChocoPackage -PackageName googlechrome,firefox

Name         CurrentVersion Version       Pinned
----         -------------- -------       ------
GoogleChrome 75.0.3770.142  75.0.3770.142 No
Firefox      68.0.1         68.0.1        No


 #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$PackageNames
    )
    $PackageNames | ForEach-Object {
        $LatestPackage = (choco list $_ --exact --source=chocolatey -r)
        if ($LatestPackage){
            [PSCustomObject]@{
                Name = $LatestPackage.Split('|')[0]
                CurrentVersion = 'None'
                Version = $LatestPackage.Split('|')[1]
                Pinned = 'No'
            }
        }
        else {
            Write-Error "Could not find latest version of package $_"
        }
    }
}