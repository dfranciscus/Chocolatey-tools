Function Get-ChocoPackageMetaData {
    <#
    .SYNOPSIS
    Return package metadata from a given Chocolatey Package(s)

    .DESCRIPTION
    Reads the contents of the nupkg and extracts metadata from the nuspec contained within it

    .PARAMETER ChocolateyPackage
    The chocolatey package(s) you wish to extract data from

    .EXAMPLE
    Get-ChocoPackageMetaData -ChocolateyPackage C:\Packages\googlechrome.nupkg

    .NOTES
    Written by Stephen Valdinger of Chocolatey Software for Dan Franciscus
    #>

    [cmdletBinding()]
    Param(
        [ValidateScript({Test-Path $_})]
        [String[]]
        $ChocolateyPackage
    )

    begin { $null = Add-Type -Assemblyname "System.IO.Compression.Filesystem" }

    process {
        Foreach($package in $ChocolateyPackage){
            $obj = @{}
            $entry =  [IO.Compression.Zipfile]::OpenRead($package).Entries |
            Where-Object { $_.Name -match "nuspec" }
            $stream = $entry.Open()
            $reader = New-Object IO.StreamReader($stream)
            $text = $reader.ReadToEnd()
            [xml]$xml = $text
            $obj.Add("Name","$($xml.package.metadata.id)")
            $obj.Add("Version","$($xml.package.metadata.version)")
            $reader.Close()
            $stream.Close()
            [pscustomobject]$obj

        }
    }
}