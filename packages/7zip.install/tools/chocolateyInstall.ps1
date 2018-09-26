Function Get-ExplorerProcessCount
{
  $process = Get-Process explorer -ErrorAction SilentlyContinue
  $processCount = ($process | Measure-Object).Count
  return $processCount
}

$initialProcessCount = Get-ExplorerProcessCount
Write-Warning "This installer is known to close the explorer process. This means `nyou may lose current work. `nIf it doesn't automatically restart explorer, type 'explorer' on the `ncommand shell to restart it."

$ErrorActionPreference = 'Stop';
$PackageParameters = Get-PackageParameters

$toolsDir   = $(Split-Path -Parent $MyInvocation.MyCommand.Definition)

If (Get-ProcessorBits -eq 64){
	$url64		    = 'https://7-zip.org/a/7z1604-x64.exe'
	$checksum64         = 'c5ec75c033970fefe0183285e35360308caa6094ded453bc5542761cd2b569a176183ca357bbdad764fa55ff42ed1d2f58f4bfec0be35b544becf32f427eb6ff'
	$checksumType64     = 'SHA512'
}

Else{
	$url		  = 'https://7-zip.org/a/7z1604.exe'
	$checksum         = '939869d9a60571c2f380ffe29ec40e7930d47e8295a2995e9ec56143319584b809fddd39a6e9df6e4b7c5e29b4925f588ca483e3c6f6758c5db54e13e2a3388c'
	$checksumType     = 'SHA512'
}

Import-Module -Name "$($toolsDir)\helpers.ps1"

$packageArgs = @{
	packageName   = '$env:ChocolateyPackageName'
	fileType      = 'exe'
	file          = "$($ENV:TMP)\7zip$($packageVersion).exe"
	silentArgs    = '/qn'
}

Install-ChocolateyInstallPackage @packageArgs

$finalProcessCount = Get-ExplorerProcessCount
if($initialProcessCount -lt $finalProcessCount)
{
  Start-Process explorer.exe
}
