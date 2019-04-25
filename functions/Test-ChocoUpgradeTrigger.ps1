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
    function Test-ChocoUpgradeTrigger {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
            [pscustomobject[]]$PackageNames,
            [Parameter(Mandatory=$true)]
            [string[]]$TriggerPackages,
            [Parameter(Mandatory=$true)]
            [string]$UpgradeScriptPath,
            [System.Management.Automation.PSCredential]$Credential
        )
        process {
            foreach ($Package in $PackageNames){
                if ($TriggerPackages -contains $Package.Name){
                    Write-Output  "Creating scheduled task"
                    Disable-ScheduledTask -TaskName 'Triggered Choco Upgrade' | Unregister-ScheduledTask -Confirm:$False
                    $Time = New-ScheduledTaskTrigger -At '11:59 PM' -Once
                    $PS = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-file $UpgradeScriptPath"
                    Register-ScheduledTask -User $Credential.UserName -Description 'This task is created when a popular third party software should be updated on clients' -TaskName 'Triggered Choco Upgrade' -Trigger $Time -Action $PS -Password $Credential.GetNetworkCredential().password -RunLevel Highest
                    Exit
                }
            }
        }
    }