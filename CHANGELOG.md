# Chocolatey-tools Release History
## 0.4.10 - 7/26/2019

### Added
*Get-LatestChocoPackage - retrives latest version of package from community repo.
*Add-ChocoIntPackage - Internalizes, installs and pushes a new package to an internal repo.

### Fixed
* Put comment-based help in right place in functions.
## 0.4.10 - 7/15/2019

### Added

* Changed Invoke-CommandAs version to 3.1.5

## 0.4.9 - 7/11/2019

### Fixed

* In Start-ChocoRemoteMgmt package installs and upgrades were not working due to an accidental deletion of -ArgumentList in Invoke-CommandAs.

* Fixed output for list and outdated buttons so that if a package is selected it does not display.

## 0.4.8 - 7/11/2019

### Added

* Module dependency for Invoke-CommandAs version 2.2

## 0.4.7 - 7/10/2019

### Fixed

* Help stuff

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


