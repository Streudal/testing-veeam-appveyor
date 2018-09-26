import-module au

$url                 = 'https://www.7-zip.org/'
$checksumTypeZip     = "SHA512"

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1'   = @{
            "(^\s*[$]*url\s*=\s*)('.*')"                 = "`$1'$($Latest.URL)'"
            "(^\s*[$]*checksum\s*=\s*)('.*')"         = "`$1'$($Latest.Checksum)'"
            "(^\s*[$]*checksumType\s*=\s*)('.*')"     = "`$1'$($Latest.ChecksumType)'"
        };
    }
    @{
        'tools\chocolateyInstall.ps1'   = @{
            "(^\s*[$]*url64\s*=\s*)('.*')"                 = "`$1'$($Latest.URL64)'"
            "(^\s*[$]*checksum64\s*=\s*)('.*')"         = "`$1'$($Latest.Checksum64)'"
            "(^\s*[$]*checksumType64\s*=\s*)('.*')"     = "`$1'$($Latest.ChecksumType64)'"
        };
}

function global:au_GetLatest {
    
    $download_page = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive

    $reLatestbuild = "(.*7-Zip.*)"
    $download_page.RawContent -imatch $reLatestbuild
    $latestbuild = $Matches[0-1]

    $reVersion = "\bv?[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)(?:\.[0-9]+)?\b"
    $latestbuild -imatch $reVersion
    $version = $Matches[0-1]
    
    If (Get-ProcessorBits -eq 64){
    $urlPackage = "https://7-zip.org/a/7z$($version)-x64.exe"
    
        return @{
        URL64                 = $urlPackage;
        ChecksumType64        = $checksumType;
        Version               = $version
        }
    }
    else {
    $urlPackage = "https://7-zip.org/a/7z$($version).exe"
        return @{
        URL                 = $urlPackage;
        ChecksumType        = $checksumType;
        Version             = $version
        }
    }


}

function global:au_AfterUpdate ($Package) {
    Set-DescriptionFromReadme $Package -SkipFirst 3
}

update
