function Invoke-BoxStarterRemoteUpgrade {
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

   #Create dynamic upgrade list
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
            Add-Content $ScriptPath -Value "choco upgrade $_ -r -y --timeout=600"
        }
    }
    #Upgrade computers with Boxstarter
    if (!$Parallel){
        Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $ScriptPath
    }
    else {
        #Upgrade computers in parallel with Boxstarter
        $ComputerName | ForEach-Object {
              start-process -RedirectStandardOutput C:\Windows\Temp\$_.txt -FilePath powershell -ArgumentList "-windowstyle hidden Install-BoxstarterPackage -ComputerName $_ -PackageName $ScriptPath" -PassThru
            }
    }
}