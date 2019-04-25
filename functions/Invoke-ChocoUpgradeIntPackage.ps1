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
            #If failure detected in output continue to next package
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