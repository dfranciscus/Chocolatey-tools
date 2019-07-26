function Invoke-ChocoInternalizePackage {
<#
.SYNOPSIS
    Takes PSobject as input to internalize packages
.DESCRIPTION
    Long description
.EXAMPLE
S C:\> $Outdatedpkgs = Get-ChocoOutdatedPackages
PS C:\> Invoke-ChocoInternalizePackage -PackageNames $Outdatedpkgs -Path $Path `
-PurgeWorkingDirectory | Where-Object { $_.Result -Like 'Internalize Success' }

Name         Result              Version       NuGetpkgs
----         ------              -------       ---------
curl         Internalize Success 7.64.1        C:\Chocotemp\curl.7.64.1.nupkg
GoogleChrome Internalize Success 74.0.3729.131 {C:\Chocotemp\chocolatey-core.extension.1.3.3.nupkg, C:\Chocotemp\Googl...

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [pscustomobject[]]$PackageNames,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [switch]$PurgeWorkingDirectory
    )
    begin {
        if (-not (Test-Path -Path  $env:ChocolateyInstall\license\chocolatey.license.xml)){
            Throw 'Chocolatey license not found. Internalizing is only supported in licensed versions.'
            return
        }
        if ($PurgeWorkingDirectory){
            Get-ChildItem -Path $Path -Recurse | Remove-Item -Recurse -Force
        }
    }
    process {
        Set-Location $Path
        foreach ($Package in $PackageNames){
            Write-Verbose ("Downloading " + $Package.Name)
            $Date = Get-Date
            choco download $Package.Name --internalize --no-progress --internalize-all-urls --source chocolatey -r | Write-Verbose
            $DownloadedPackages = Get-ChildItem -Path $Path | Where-Object {$_.Extension -eq '.nupkg' -AND $_.LastWriteTime -gt $Date} | Select-Object -ExpandProperty FullName
            if ($LASTEXITCODE -ne 0){
                $Result = 'Internalize Failed'
            }
            else {
                $Result = 'Internalize Success'
            }
            Write-Verbose ($Package.Name + ' internalize failed')
            [PSCustomObject]@{
                Name = $Package.Name
                Result = $Result
                Version = $Package.Version
                NuGetpkgs = $DownloadedPackages
                }
        }
    }
}