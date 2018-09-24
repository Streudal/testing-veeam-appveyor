import-module au

$url                 = 'https://forums.veeam.com/veeam-agent-for-windows-f33/current-version-t29537.html'
$checksumTypeZip     = "SHA512"

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1'   = @{
            "(^\s*[$]*url\s*=\s*)('.*')"                 = "`$1'$($Latest.URL64)'"
            "(^\s*[$]*checksumZip\s*=\s*)('.*')"         = "`$1'$($Latest.Checksum64)'"
            "(^\s*[$]*checksumTypeZip\s*=\s*)('.*')"     = "`$1'$($Latest.ChecksumType64)'"
        };
    }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive

    $reLatestbuild = "(.*7-Zip.*)"
    $download_page.RawContent -imatch $reLatestbuild
    $latestbuild = $Matches[1]

    $reVersion = "\bv?[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)(?:\.[0-9]+)?\b"
    $latestbuild -imatch $reVersion
    $version = $Matches[1]

    $urlPackage = "https://7-zip.org/a/7z$($version)-x64.exe"

    return @{
        URL64                 = $urlPackage;
        ChecksumType64        = $checksumTypeZip;
        Version               = $version
    }
}

function global:au_AfterUpdate ($Package) {
    Set-DescriptionFromReadme $Package -SkipFirst 3
}

update