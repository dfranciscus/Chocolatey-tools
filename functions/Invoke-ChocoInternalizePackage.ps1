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
function Invoke-ChocoInternalizePackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [pscustomobject[]]$PackageNames,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [switch]$PurgeWorkingDirectory
    )
    begin {
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