<#
.SYNOPSIS
Takes PSobject to perform a choco upgrade an each package
.EXAMPLE
    PS C:\> $intpkgs = Invoke-ChocoInternalizePackage -PackageNames $Outdatedpkgs -Path $Path `
-PurgeWorkingDirectory | Where-Object { $_.Result -Like 'Internalize Success' }

PS C:\Chocotemp> Invoke-ChocoUpgradeIntPackage -PackageNames $intpkgs -Path $Path |
 Where-Object {$_.Result -eq 'Upgrade Success'}

Name         Result          Version       NuGetpkgs
----         ------          -------       ---------
curl         Upgrade Success 7.64.1        C:\Chocotemp\curl.7.64.1.nupkg
GoogleChrome Upgrade Success 74.0.3729.131 {C:\Chocotemp\chocolatey-core.extension.1.3.3.nupkg, C:\Chocotemp\GoogleChr...

#>
function Invoke-ChocoUpgradeIntPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [pscustomobject[]]$PackageNames,
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    process {
        foreach ($Package in $PackageNames){
            Write-Verbose ("Upgrading " + $Package.Name)
            choco upgrade $Package.Name --source $Path --no-progress -y -r | Write-Verbose
            if ($LASTEXITCODE -ne 0){
                $Result = 'Upgrade Failed'
            }
            else {
                $Result = 'Upgrade Success'
            }
                Write-Verbose ($Package.Name + ' Upgrade failed')
                [PSCustomObject]@{
                    Name = $Package.Name
                    Result = $Result
                    Version = $Package.Version
                    NuGetpkgs = $Package.NuGetpkgs
                 }
            }
        }
    }
