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
function Get-ChocoOutdatedPackages {
    [CmdletBinding()]
    param(
    )
        Write-Verbose "Getting local outdated packages"
        $OutdatedPackages = (choco outdated -r --ignore-pinned --ignore-unfound --timeout=60)
        if ($LASTEXITCODE -eq 1){
            Write-Verbose -Message 'Error getting outdated packages'
            $OutdatedPackages
            Exit
        }
        #If no updated packages are available then exit
        if ($LASTEXITCODE -eq 0){
            Write-Verbose -Message 'No new packages available. Exiting'
            Exit
        }
        else {
           # $NewPackages =
        foreach ($NewPackage in $OutdatedPackages){
            [PSCustomObject]@{
                Name = $NewPackage.Split('|')[0]
                CurrentVersion = $NewPackage.Split('|')[1]
                Version = $NewPackage.Split('|')[2]
                Pinned = $NewPackage.Split('|')[3]
            }
        }
    }
}