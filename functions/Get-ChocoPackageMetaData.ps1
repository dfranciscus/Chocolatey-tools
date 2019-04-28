Function Get-ChocoPackageMetaData {
    <#
    .SYNOPSIS
    Return package metadata from a given Chocolatey Package(s)

    .DESCRIPTION
    Reads the contents of the nupkg and extracts metadata from the nuspec contained within it

    .PARAMETER ChocolateyPackage
    The chocolatey package(s) you wish to extract data from

    .PARAMETER AdditonalInformation
    Return more information about the package than the default ID and Version

    .EXAMPLE
    Get-ChocoPackageMetaData -ChocolateyPackage C:\Packages\googlechrome.nupkg

    .EXAMPLE
    Get-ChocoPackageMetaData -ChocolateyPackage C:\Packages\googlechrome.nupkg -AdditionalInformation Owners,Description,ProjectUrl,Dependencies
    .NOTES
    Written by Stephen Valdinger of Chocolatey Software for Dan Franciscus

    Dependencies work a little funny in how they get stuffed into the object. They come back as an object themselves, so special care must be taken to unroll them.

    e.g.
    Get-ChocoPackageMetaData -ChocolateyPackage C:\packages\googlechrome.nupkg -AdditionalInformation Dependencies | Select-Object -ExpandProperty Dependencies
    #>

    [cmdletBinding()]
    Param(
        [ValidateScript({Test-Path $_})]
        [String[]]
        $ChocolateyPackage,

        [Parameter()]
        [String[]]
        [ValidateSet('Authors','Description','ProjectUrl','Owners','Licenseurl','Iconurl','Dependencies')]
        $AdditionalInformation
    )

    begin { $null = Add-Type -Assemblyname "System.IO.Compression.Filesystem" }

    process {
        Foreach($package in $ChocolateyPackage){
            $obj = [ordered]@{}
            $entry =  [IO.Compression.Zipfile]::OpenRead($package).Entries |
            Where-Object { $_.Name -match "nuspec" }
            $stream = $entry.Open()
            $reader = New-Object IO.StreamReader($stream)
            $text = $reader.ReadToEnd()
            [xml]$xml = $text
            $obj.Add("Name","$($xml.package.metadata.id)")
            $obj.Add("Version","$($xml.package.metadata.version)")

           Foreach($member in $AdditionalInformation){

                if($member -eq 'Dependencies'){
                    $obj.Add("$member",$($xml.package.metadata.dependencies.dependency | Select-Object Id,Version))
                }

                else{
                    $obj.Add("$member",$($xml.package.metadata.$($member)))
                }

           }

            $reader.Close()
            $stream.Close()
            [pscustomobject]$obj

        }
    }
}