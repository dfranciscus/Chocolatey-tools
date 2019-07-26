
function Invoke-BoxStarterRemoteUpgrade {
<#
.SYNOPSIS
    Uses Install-Boxstarterpackage to install packages remotely. In addition, provides ability to deploy new packages and exclude packages.
.DESCRIPTION
    Long description
.EXAMPLE
    Here, we upgrade any out of date packages on winclient2, push out curl and git packages and exclude jre8 from updating.
    Each of these commands is created dynamically at runtime on a text file on the local machine called Boxstarterupgrade.txt

    Invoke-BoxStarterRemoteUpgrade -ComputerName winclient2 -Credential $DomainCred -AdditionalPackages curl,git -ExcludedPackages jre8 -ScriptPath C:\Windows\Temp\BoxstarterUpgrade.txt
.EXAMPLE
     Here we use the -Parallel switch so that each remote machine is processed at the same time.

      Invoke-BoxStarterRemoteUpgrade -ComputerName winclient2 -Credential $DomainCred -AdditionalPackages curl,git -Parallel -ScriptPath C:\Windows\Temp\BoxstarterUpgrade.txt
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,
        [string[]]$AdditionalPackages,
        [string[]]$ExcludedPackages,
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        [switch]$Parallel
    )

    Invoke-Command -ArgumentList $AdditionalPackages,$ExcludedPackages,$ScriptPath -ComputerName $ComputerName -ScriptBlock {
        param (
            $AdditionalPackages,
            $ExcludedPackages,
            $ScriptPath
        )
        if (Test-Path $ScriptPath) {
            Remove-Item $ScriptPath -Force
        }
            $packages = [System.Collections.ArrayList]@(choco outdated -r --ignore-unfound --ignore-pinned  | Foreach-Object {
                ($_.split("|"))[0]
            })
        foreach ($AddedPackage in $AdditionalPackages){
            if ($packages -notcontains $AddedPackage){
                $packages.Add($AddedPackage) | Out-Null
            }
        }
        foreach ($ExcludedPackage in $ExcludedPackages){
            if ($packages -contains $ExcludedPackage){
                $packages.Remove($ExcludedPackage) | Out-Null
            }
        }
        $Packages | ForEach-Object {
            Add-Content $ScriptPath -Value "choco upgrade $_ -r -y"
        }
    }
    if (!$Parallel){
        Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $ScriptPath -DelegateChocoSources
    }
    else {
        $ComputerName | ForEach-Object {
              start-process -RedirectStandardOutput C:\Windows\Temp\$_.txt -FilePath powershell -ArgumentList "-windowstyle hidden Install-BoxstarterPackage -ComputerName $_ -PackageName $ScriptPath" -PassThru
            }
    }
}
