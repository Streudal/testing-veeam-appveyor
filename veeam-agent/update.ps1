import-module au

$url                 = 'https://forums.veeam.com/veeam-agent-for-windows-f33/current-version-t29537.html'
$checksumTypeZip         = "MD5"

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1'   = @{
            "(^\s*[$]*url\s*=\s*)('.*')"                 = "`$1'$($Latest.URL)'"
            "(^\s*[$]*checksumZip\s*=\s*)('.*')"         = "`$1'$($Latest.Checksum)'"
            "(^\s*[$]*checksumTypeZip\s*=\s*)('.*')"     = "`$1'$($Latest.ChecksumTypeZip)'"
        };
    }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive

    $reLatestbuild = "(.*Latest build.*)"
    $download_page.RawContent -imatch $reLatestbuild
    $latestbuild = $Matches[0]

    $reVersion = "\bv?[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)(?:\.[0-9]+)?\b"
    $latestbuild -imatch $reVersion
    $version = $Matches[0]

    $urlPackage = "https://download5.veeam.com/VeeamAgentWindows_$($version).zip"

    return @{
        URL                   = $urlPackage;
        ChecksumType          = $checksumTypeZip;
        Version               = $version
    }
}

function global:au_AfterUpdate ($Package) {
    Set-DescriptionFromReadme $Package -SkipFirst 3
}

update
