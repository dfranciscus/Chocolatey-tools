 There are various ways to internalize community packages. The approach in this example is that you have a machine with all packages that you want to internalize already installed. This machine will perform choco outdated to find any packages that have newer versions available on the Chocolatey community repo. It then internalizes them, upgrades them to test they work, finally pushing them to an internal repo.

### Find outdated packages
```
PS C:\> $Outdatedpkgs = Get-ChocoOutdatedPackages
PS C:\> $Outdatedpkgs

Name                 CurrentVersion Version       Pinned
----                 -------------- -------       ------
chocolatey.extension 2.0.1          2.0.2         false
curl                 7.64.0         7.64.1        false
GoogleChrome         73.0.3683.103  74.0.3729.131 false
```
### Internalize outdated packages
```
PS C:\> $intpkgs = Invoke-ChocoInternalizePackage -PackageNames $Outdatedpkgs -Path $Path `
-PurgeWorkingDirectory | Where-Object { $_.Result -Like 'Internalize Success' }
PS C:\Chocotemp> $intpkgs

Name         Result              Version       NuGetpkgs
----         ---the ---              -------       ---------
curl         Internalize Success 7.64.1        C:\Chocotemp\curl.7.64.1.nupkg
GoogleChrome Internalize Success 74.0.3729.131 {C:\Chocotemp\chocolatey-core.extension.1.3.3.nupkg, C:\Chocotemp\Googl...
```
### Upgrade internalized packages to ensure they install correctly.
```
PS C:\Chocotemp> $Upgradepkgs = Invoke-ChocoUpgradeIntPackage -PackageNames $intpkgs -Path $Path |
 Where-Object {$_.Result -eq 'Upgrade Success'}
PS C:\Chocotemp> Where-Object {$_.Result -eq 'Upgrade Success'}
$Upgradepkgs

Name         Result          Version       NuGetpkgs
----         ------          -------       ---------
curl         Upgrade Success 7.64.1        C:\Chocotemp\curl.7.64.1.nupkg
GoogleChrome Upgrade Success 74.0.3729.131 {C:\Chocotemp\chocolatey-core.extension.1.3.3.nupkg, C:\Chocotemp\GoogleChr...
```
### Push packages that were successfully upgrade to an internal repo
```
PS C:\Chocotemp> $Pushed = Push-ChocoIntPackage -PackageNames $Upgradepkgs -Path $Path `
-ApiKey $Api -RepositoryURL $LocalRepo |
Where-Object {$_.Result -like 'Push Success'}
PS C:\Chocotemp> $Pushed

Name                      Result       Version       NuGetPackage
----                      ------       -------       ------------
curl                      Push Success 7.64.1        C:\Chocotemp\curl.7.64.1.nupkg
chocolatey-core.extension Push Success 1.3.3         C:\Chocotemp\chocolatey-core.extension.1.3.3.nupkgpkg
GoogleChrome              Push Success 74.0.3729.131 C:\Chocotemp\GoogleChrome.74.0.3729.131.nupkg
}
```
### Here we pipe all commands together and add Test-ChocoUpgradeTrigger which takes any successfully pushed packages and creates a scheduled task for a PowerShell upgrade script.
```
PS C:\Chocotemp> Get-ChocoOutdatedPackages |
Invoke-ChocoInternalizePackage -Path $Path -PurgeWorkingDirectory | Where-Object { $_.Result -Like 'Internalize Success' } |
Invoke-ChocoUpgradeIntPackage -Path $Path | Where-Object {$_.Result -eq 'Upgrade Success'} |
Push-ChocoIntPackage -Path $Path -ApiKey $Api -RepositoryURL $LocalRepo |
Test-ChocoUpgradeTrigger -TriggerPackages 'googlechrome' -UpgradeScriptPath c:\test.ps1 -TriggeredTime '12 PM' -Credential $DomainCred
Creating scheduled task for GoogleChrome

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\                                              Triggered Choco Upgrade           Ready
```


