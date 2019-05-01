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
function Invoke-ChocoRemoteUpgrade {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [pscredential]$Credential,
        [string[]]$AdditionalPackages,
        [string[]]$ExcludedPackages,
        [switch]$RebootifPending
    )
    process {
        #Create dynamic upgrade list
    Invoke-Command -ArgumentList $AdditionalPackages,$ExcludedPackages,$ScriptPath,$Credential -ComputerName $ComputerName -ScriptBlock {
        param (
            $AdditionalPackages,
            $ExcludedPackages,
            $ScriptPath
        )
        $packages = [System.Collections.ArrayList]@(choco outdated -r --ignore-unfound --ignore-pinned  | Foreach-Object {
                ($_.split("|"))[0]
        })
        if ($AdditionalPackages){
            foreach ($AddedPackage in $AdditionalPackages){
                if ($packages -notcontains $AddedPackage){
                    $packages.Add($AddedPackage) | Out-Null
                }
            }
        }
        if ($ExcludedPackages){
            foreach ($ExcludedPackage in $ExcludedPackages){
                if ($packages -contains $ExcludedPackage){
                    $packages.Remove($ExcludedPackage) | Out-Null
                }
            }
        }
        foreach ($package in $packages){
            choco upgrade $package -r -y --timeout=600 | Out-File ("c:\Windows\Temp\choco-" + $package + ".txt")
            if ($LASTEXITCODE -ne 0){
                $Result = 'Failed'
            }
            else{
                $Result = 'Success'
            }
            [PSCustomObject]@{
                Name = $Package
                Result = $Result
                Computer = $Env:COMPUTERNAME
            }
        }
    }
    #Restart machines with pending Reboot
    if ($RebootifPending){
        Test-PendingReboot -ComputerName $ComputerName -SkipConfigurationManagerClientCheck | Where-Object {$_.IsRebootpending -eq $True } | ForEach-Object {
            "Rebooting $($_.ComputerName)"
            Restart-Computer -ComputerName $_.ComputerName -Force
        }
    }
   }
}