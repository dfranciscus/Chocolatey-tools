# Chocolatey-tools Release History

## 0.4.5 - 7/10/2019

### Added

* Start-ChocoRemotemgmt - A Winforms GUI that can install,uninstall,upgrade,view, see outdated packages on remote Chocolatey clients
* Get-ChocoSourcepackages - Helper function for getting packages from multiple Chocolatey sources for Start-ChocoRemotemgmt
* Invoke-RebootPrompt - Helper function for prompting to reboot a machine remotely in Start-ChocoRemotemgmt

## 0.4.3 - 6/5/2019

### Fixed

* Get-ChocoOutdatedPackages was failing due to change in $LASTEXITCODE handling in latest
Chocolatey version (0.10.15)
* Second item fixed


