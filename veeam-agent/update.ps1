import-module au

$url = 'https://forums.veeam.com/veeam-agent-for-windows-f33/current-version-t29537.html'


function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1'   = @{
            "(^\s*[$]*url\s*=\s*)('.*')"                 = "`$1'$($Latest.URL64)'"
            "(^\s*[$]*checksumZip\s*=\s*)('.*')"         = "`$1'$($Latest.Checksum64)'"
        };
    }
}

function global:au_BeforeUpdate (){
   $au_GalleryUrl = 'https://github.com/tastreu/testing-veeam-appveyor.git'
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive

    $reLatestbuild = "(.*Latest build.*)"
    $download_page.RawContent -imatch $reLatestbuild
    $latestbuild = $Matches[0]

    $reVersion = "\bv?[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)(?:\.[0-9]+)?\b"
    $latestbuild -imatch $reVersion
    $version = $Matches[0]

    $url= "https://download5.veeam.com/VeeamAgentWindows_$($version).zip"

    return @{
        URL64                 = $url;
        Version               = $version
    }
}

function global:au_AfterUpdate ($Package) {
    Set-DescriptionFromReadme $Package -SkipFirst 3
}

update -ChecksumFor 64
