The Start-ChocoRemoteMgmt function launches a Winform PowerShell GUI for installing, uninstall, upgrading, viewing Chocolatey packages on remote clients. It can also be used to see current logged on users and reboot machines.

Note that the GUI will freeze when it is performing an action. The output will be displayed when it is finished. The list box of computers also does autocomplete, which is nice when you have a lot of computers.

### Prerequisites:
- Invoke-CommandAs PowerShell community module (Used for running scheduled tasks as SYSTEM)
- Chocolatey installed on remote machines

Here I use Active Directory to get a list of all computers which will populate the computer list in the GUI. I also use the function Get-ChocoSourcePackages to get all of the packages from my the local sources I have configured in Chocolatey. Note that it will only get unique package names.
```
Start-ChocoRemoteMgmt -ComputerName (Get-ADComputer -Filter * | Select-Object -ExpandProperty Name) -Packages (Get-ChocoSourcePackages -Packages myrepo1,myrepo2,myrepo3)
```
![alt text](https://github.com/dfranciscus/Chocolatey-tools/Examples/ChocoRemoteGUI.JPG "Chocolatey GUI")


