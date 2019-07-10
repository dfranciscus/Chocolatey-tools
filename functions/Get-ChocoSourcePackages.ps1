<#
 .SYNOPSIS
     Outputs all package names for one or multiple Chocolatey sources.
 .EXAMPLE
     Get-ChocoSourcePackages -Sources repo1,repo2
 #>
 function Get-ChocoSourcePackages {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Sources
    )
    $Sources | ForEach-Object {
       choco list --source=$_ -r | ForEach-Object {$_.split("|")[0]}
    } | Sort-Object -Unique
}