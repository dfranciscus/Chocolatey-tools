
function Add-ChocoIntPackage {
<#
 .SYNOPSIS
     Internalizes, tests the installation and pushes new Chocolatey packages to a internal repository
 .EXAMPLE
      Here I internalize the Firefox and Google Chrome packages from the community repo and push to my internal repo.

      Add-ChocoIntPackage -PackageNames firefox,googlechrome -Path C:\Chocotemp\ -RepositoryURL 'https://myrepo/chocolatey' -ApiKey (Get-Credential)
 #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string[]]$PackageNames,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryURL,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]$ApiKey
    )
    try {
        Get-LatestChocoPackage -PackageNames $PackageNames |
        Invoke-ChocoInternalizePackage -Path $Path -PurgeWorkingDirectory |
        Where-Object { $_.Result -Like 'Internalize Success' } |
        Invoke-ChocoUpgradeIntPackage -Path $Path -ErrorAction Stop |
        Where-Object {$_.Result -eq 'Upgrade Success'} |
        Push-ChocoIntPackage -Path $Path -ApiKey $Apikey -RepositoryURL $RepositoryURL -ErrorAction Stop
    }
    catch {
        $Error[0] | Select-Object -Property Exception,ScriptStackTrace | Format-list
    }
}
