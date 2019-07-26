
function Push-ChocoIntPackage {
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
PS C:\Chocotemp> $Upgradepkgs = Invoke-ChocoUpgradeIntPackage -PackageNames $intpkgs -Path $Path |
 Where-Object {$_.Result -eq 'Upgrade Success'}

PS C:\Chocotemp> Push-ChocoIntPackage -PackageNames $Upgradepkgs -Path $Path `
-ApiKey $Api -RepositoryURL $LocalRepo |
Where-Object {$_.Result -like 'Push Success'}

Name                      Result       Version       NuGetPackage
----                      ------       -------       ------------
curl                      Push Success 7.64.1        C:\Chocotemp\curl.7.64.1.nupkg
chocolatey-core.extension Push Success 1.3.3         C:\Chocotemp\chocolatey-core.extension.1.3.3.nupkgpkg
GoogleChrome              Push Success 74.0.3729.131 C:\Chocotemp\GoogleChrome.74.0.3729.131.nupkg

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [pscustomobject[]]$PackageNames,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryURL,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]$ApiKey
    )
    process {
        foreach ($Package in $PackageNames){
            foreach ($NuPkg in $Package.NuGetpkgs) {
                $MetaData = Get-ChocoPackageMetaData -ChocolateyPackage $NuPkg
                choco push $NuPkg --force --source $RepositoryURL --api-key $ApiKey.GetNetworkCredential().Password --timeout=3600 | Write-Verbose
                if ($LASTEXITCODE -ne 0){
                   $Result = 'Push Failed'
                }
                else {
                    $Result = 'Push Success'
                }
                    Write-Verbose "$($MetaData.Name) push failed"
                    [PSCustomObject]@{
                        Name = $MetaData.Name
                        Result = $Result
                        Version = $MetaData.Version
                        NuGetPackage = $NuPkg
                        }
                }
            }
        }
    }