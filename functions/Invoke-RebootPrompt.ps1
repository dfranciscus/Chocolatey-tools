
Function Invoke-RebootPrompt {
<#
 .SYNOPSIS
     Used in Start-ChocoRemotemgmt to prompt if a user wants to reboot a computer.
 #>
param(
    $Message = "Click OK to reboot",
    $Title = "Continue or Cancel"
)
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    $MsgBox = [System.Windows.Forms.MessageBox]
    $Decision = $MsgBox::Show($Message,$Title,"OkCancel", "Information")
    If ($Decision -ne "Cancel") {
        $outputBox.Text = ""
        try {
            $outputBox.Text = ("Rebooting " +  $ComputerList.Text)
            Restart-Computer -ComputerName $ComputerList.Text -Force -ErrorAction stop
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $outputBox.Text = $ErrorMessage
        }
    }
}