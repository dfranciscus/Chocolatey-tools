<#
.SYNOPSIS
    Use PowerShell remoting with to remotely update clients by adding and excluding packages. This function uses
    Invoke-Command to connect and run choco upgrade for any outdated packages.
.EXAMPLE
    PS C:\Chocotemp> Invoke-ChocoRemoteUpgrade -ComputerName winclient,winclient2 -Credential $DomainCred `
 -AdditionalPackages firefox -RebootifPending | Select-Object -Property Name,Result,Computer |
 Format-List


Name     : googlechrome
Result   : Failed
Computer : WINCLIENT2

Name     : googlechrome
Result   : Failed
Computer : WINCLIENT

Name     : firefox
Result   : Success
Computer : WINCLIENT2

Name     : firefox
Result   : Success
Computer : WINCLIENT
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
    if ($RebootifPending){
        Test-PendingReboot -ComputerName $ComputerName -SkipConfigurationManagerClientCheck | Where-Object {$_.IsRebootpending -eq $True } | ForEach-Object {
            "Rebooting $($_.ComputerName)"
            Restart-Computer -ComputerName $_.ComputerName -Force
        }
    }
   }
}