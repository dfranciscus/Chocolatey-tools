 #requires -modules Invoke-CommandAs

function Start-ChocoRemoteMgmt {
 <#
 .SYNOPSIS
     Starts a Winforms GUI for remote management of Chocolatey clients.
 .EXAMPLE
     In this example, we query Active Directory for all computers which will populate the list of computers.
     We also use the function Get-ChocoSourcePackages to pull all packages from Chocolatey sources configured on the local computer.

     Start-ChocoRemotemgmt -ComputerName (Get-ADComputer -Filter | Select-Object -ExpandProperty Name) -Packages (Get-ChocoSourcePackages -Sources repo1,repo2)

     Button actions:

     Reboot - Will prompt for confirmation and reboot the computer shown in Computer Name.
     Show Current User - Show the current logged on user for remote computer.
     Show Outdated - Show what Chocolatey packages are outdated on the remote machine.
     Install - Install a Chocolatey package that is selected from the Packages list on the remote computer.
     Upgrade - Upgrade a Chocolatey package that is selected from the Packages list on the remote computer.
     Unistall - Upgrade - Uninstall a Chocolatey package that is selected from the Packages list on the remote computer.
     Show Installed - Show what Chocolatey packages and versions are installed on remote computer.
 #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string[]]$Packages
    )
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $Form = New-Object system.Windows.Forms.Form
    $Form.Text = "Chocolatey Remote Management"
    $Form.TopMost = $true
    $Form.Width = 757
    $Form.Height = 570

    $ComputerNameLabel = New-Object system.windows.Forms.Label
    $ComputerNameLabel.Text = "Computer Name"
    $ComputerNameLabel.AutoSize = $true
    $ComputerNameLabel.Width = 25
    $ComputerNameLabel.Height = 10
    $ComputerNameLabel.location = new-object system.drawing.point(28,23)
    $ComputerNameLabel.Font = "Microsoft Sans Serif,12"

    $Form.controls.Add($ComputerNameLabel)

    $ComputerList = New-Object system.windows.Forms.TextBox
    $ComputerList.Width = 180
    $ComputerList.Height = 20
    $ComputerList.location = new-object system.drawing.point(28,55)
    $ComputerList.Font = "Microsoft Sans Serif,12"
    $ComputerList.AutoCompleteSource = 'CustomSource'
    $ComputerList.AutoCompleteMode='SuggestAppend'
    $ComputerList.AutoCompleteCustomSource=$Autocomplete
    $ComputerName | ForEach-Object {$ComputerList.AutoCompleteCustomSource.AddRange($_) }
    $Form.controls.Add($ComputerList)

    $PackageList = New-Object system.windows.Forms.ListBox
    $PackageList.Text = "PackageList"
    $PackageList.Width = 325
    $PackageList.Height = 129
    $PackageList.Font = "Microsoft Sans Serif,12"
    $PackageList.location = new-object system.drawing.point(241,54)
    $Packages | ForEach-Object { $PackageList.Items.Add($_) | Out-Null }
    $Form.controls.Add($PackageList)

    $PackagesList = New-Object system.windows.Forms.Label
    $PackagesList.Text = "Packages"
    $PackagesList.AutoSize = $true
    $PackagesList.Width = 25
    $PackagesList.Height = 10
    $PackagesList.location = new-object system.drawing.point(240,23)
    $PackagesList.Font = "Microsoft Sans Serif,12"
    $Form.controls.Add($PackagesList)

    $ShowCurrentUser = New-Object system.windows.Forms.Button
    $ShowCurrentUser.Text = "Show Current User"
    $ShowCurrentUser.Width = 148
    $ShowCurrentUser.Height = 34
    $ShowCurrentUser.location = new-object system.drawing.point(28,149)
    $ShowCurrentUser.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($ShowCurrentUser)
    $ShowCurrentUser.add_Click({
    $outputBox.Text = ("Find current user on " + $ComputerList.Text)
        if (!(Test-Connection -ComputerName $ComputerList.text -Count 2)){
            $outputBox.Text = "Computer is not online"
        }
        else {
        $CurrentUser = Invoke-Command -ComputerName $ComputerList.text -Scriptblock {
            (Get-WMIObject -class Win32_ComputerSystem).username
        }
        $outputBox.Text = $CurrentUser
        if (!$CurrentUser ) {
            $outputBox.Text = "No user is logged on"
        }
        }
    })

    $InstallPackage = New-Object system.windows.Forms.Button
    $InstallPackage.Text = "Install"
    $InstallPackage.Width = 95
    $InstallPackage.Height = 34
    $InstallPackage.location = new-object system.drawing.point(240,185)
    $InstallPackage.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($InstallPackage)
    $InstallPackage.add_Click({
    $outputBox.Text = ""
    $outputBox.Text = ("Installing " +  $PackageList.SelectedItem + " on " +  $ComputerList.Text)
    Write-output "Installing"
    $chocoutput = Invoke-CommandAs -AsSystem -ComputerName $ComputerList.Text -ScriptBlock {
        choco install $args[0] -y -r
    } -ArgumentList $PackageList.SelectedItem
    Write-output "Done"
    $outputBox.Text = $chocoutput

})

    $Outdatepackage = New-Object system.windows.Forms.Button
    $Outdatepackage.Text = "Show Outdated"
    $Outdatepackage.Width = 107
    $Outdatepackage.Height = 34
    $Outdatepackage.location = new-object system.drawing.point(458,185)
    $Outdatepackage.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($Outdatepackage)
    $Outdatepackage.add_Click({
    $outputBox.Text = ""
    $outputBox.Text = ("Finding outdated packages on " +  $ComputerList.Text)
    Write-output "Listing installed packages"
    $chocoutput = Invoke-CommandAs -AsSystem -ComputerName $ComputerList.Text -ScriptBlock {
        choco outdated -r --ignore-unfound --ignore-pinned  | Out-String
    }
    Write-output "Done"
    $outputBox.Text = $chocoutput
    })

    $ListPackage = New-Object system.windows.Forms.Button
    $ListPackage.Text = "Show Installed"
    $ListPackage.Width = 107
    $ListPackage.Height = 34
    $ListPackage.location = new-object system.drawing.point(343,235)
    $ListPackage.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($listPackage)
    $ListPackage.add_Click({
    $outputBox.Text = ""
    $outputBox.Text = ("Finding installed packages on " +  $ComputerList.Text)
    Write-output "Listing installed packages"
    $chocoutput = Invoke-CommandAs -AsSystem -ComputerName $ComputerList.Text -ScriptBlock {
        choco list -lo -r | Out-String }
    Write-output "Done"
    $outputBox.Text = $chocoutput
    })

    $UpgradePackage = New-Object system.windows.Forms.Button
    $UpgradePackage.Text = "Upgrade"
    $UpgradePackage.Width = 95
    $UpgradePackage.Height = 34
    $UpgradePackage.location = new-object system.drawing.point(240,235)
    $UpgradePackage.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($UpgradePackage)
    $UpgradePackage.add_Click({
    $outputBox.Text = ""
    $outputBox.Text = ("Upgrading " +  $PackageList.SelectedItem + " on " +  $ComputerList.Text)
    Write-output "Installing"
    $chocoutput = Invoke-CommandAs -AsSystem  -ComputerName $ComputerList.Text -ScriptBlock {
        choco upgrade $args[0] -y -r
    } -ArgumentList $PackageList.SelectedItem
    Write-output "Done"
    $outputBox.Text = $chocoutput
    })

    $UninstallPackage = New-Object system.windows.Forms.Button
    $UninstallPackage.Text = "Uninstall"
    $UninstallPackage.Width = 107
    $UninstallPackage.Height = 34
    $UninstallPackage.location = new-object system.drawing.point(343,185)
    $UninstallPackage.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($UninstallPackage)
    $UninstallPackage.add_Click({
    $outputBox.Text = ""
    $outputBox.Text = ("Uninstalling " +  $PackageList.SelectedItem + " on " +  $ComputerList.Text)
    Write-output "Uinstalling"
    $chocoutput = Invoke-CommandAs -AsSystem  -ComputerName $ComputerList.Text -ScriptBlock {
        choco uninstall $args[0] -y -f -r } -ArgumentList $PackageList.SelectedItem
    Write-output "Done"
    $outputBox.Text = $chocoutput
    })

    $RebootComputer = New-Object system.windows.Forms.Button
    $RebootComputer.Text = "Reboot"
    $RebootComputer.Width = 75
    $RebootComputer.Height = 34
    $RebootComputer.location = new-object system.drawing.point(28,95)
    $RebootComputer.Font = "Microsoft Sans Serif,10"
    $Form.controls.Add($RebootComputer)
    $RebootComputer.add_Click({
        Invoke-RebootPrompt
    })

    $outputBox = New-Object System.Windows.Forms.TextBox
    $OutputBox.location = new-object system.drawing.point(28,284)
    $outputBox.Size = New-Object System.Drawing.Size(400,200)
    $outputBox.MultiLine = $True
    $outputBox.ScrollBars = "Vertical"
    $outputBox.Font = "Microsoft Sans Serif,12"
    $Form.Controls.Add($outputBox)

    $Output = New-Object system.windows.Forms.Label
    $Output.Text = "Output"
    $Output.AutoSize = $true
    $Output.Width = 25
    $Output.Height = 10
    $Output.location = new-object system.drawing.point(28,252)
    $Output.Font = "Microsoft Sans Serif,12"
    $Form.controls.Add($Output)

    [void]$Form.ShowDialog()
    $Form.Dispose()
}