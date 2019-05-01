<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
#>
function Push-ChocoIntPackage {
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