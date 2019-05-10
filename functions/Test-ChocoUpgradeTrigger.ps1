    <#
    .SYNOPSIS
        Tests each package a PSObject to see if it meets an item in -TriggerPackages. If so, it will create
        a scheduled task on a local or remote machine with CIM. Use case would be a scheduled job for upgrading Chocolatey clients.
    .EXAMPLE
    Here we pipe all of the internalizing commands together with Test-Trigger.

    PS C:\Chocotemp> Get-ChocoOutdatedPackages |
    Invoke-ChocoInternalizePackage -Path $Path -PurgeWorkingDirectory | Where-Object { $_.Result -Like 'Internalize Success' } |
    Invoke-ChocoUpgradeIntPackage -Path $Path | Where-Object {$_.Result -eq 'Upgrade Success'} |
    Push-ChocoIntPackage -Path $Path -ApiKey $Api -RepositoryURL $LocalRepo |
    Test-ChocoUpgradeTrigger -TriggerPackages 'googlechrome' -UpgradeScriptPath c:\test.ps1 -TriggeredTime '12 PM' -Credential $DomainCred
    Creating scheduled task for GoogleChrome

    TaskPath                                       TaskName                          State
    --------                                       --------                          -----
        \                                              Triggered Choco Upgrade           Ready
    PS C:\Chocotemp>
    #>
    function Test-ChocoUpgradeTrigger {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
            [pscustomobject[]]$PackageNames,
            [Parameter(Mandatory=$true)]
            [string[]]$TriggerPackages,
            [Parameter(Mandatory=$true)]
            [string]$UpgradeScriptPath,
            [Parameter(Mandatory=$true)]
            [string]$TriggeredTime,
            [Parameter(Mandatory=$true)]
            [System.Management.Automation.PSCredential]$Credential,
            [String]$ComputerName
        )
        process {
            foreach ($Package in $PackageNames){
                if ($TriggerPackages -contains $Package.Name){
                    Write-Output  "Creating scheduled task because $($Package.Name) is a triggered package"
                    $Cim = New-CimSession -ComputerName $ComputerName -Credential $Credential
                    Disable-ScheduledTask -CimSession $Cim -TaskName 'Triggered Choco Upgrade' | Unregister-ScheduledTask -CimSession $Cim -Confirm:$False
                    $Time = New-ScheduledTaskTrigger -At $TriggeredTime -Once
                    $PS = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-file $UpgradeScriptPath"
                    Register-ScheduledTask -CimSession $Cim -User $Credential.UserName -Description 'This task is created when a certain third party software should be updated on clients' -TaskName 'Triggered Choco Upgrade' -Trigger $Time -Action $PS -Password $Credential.GetNetworkCredential().password -RunLevel Highest
                    Exit
                }
            }
        }
    }