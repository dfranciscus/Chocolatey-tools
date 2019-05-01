Boxstarter can be used to create a dynamic list of both outdated packages, additional packages to install and packages to exclude for each Chocolatey client

In this example, we want to add curl and git as additional packages to install and exclude Java (jre8). Note that -ScriptPath is the path that will be created with a list of choco commands for each package to install. Boxstarter will reboot if needed after each line
```
Invoke-BoxStarterRemoteUpgrade -ComputerName winclient2 -Credential (Get-Credential) `
-AdditionalPackages curl,git -ExcludedPackages jre8 `
-ScriptPath C:\Windows\Temp\BoxstarterUpgrade.txt
```
### Here is the BoxstarterUpgrade.txt file for the previous example:
```
choco upgrade curl -r -y
choco upgrade git -r -y
choco upgrade googlechrome -r -y
```