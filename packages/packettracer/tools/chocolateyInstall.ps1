$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packageName = 'packettracer'
$installerDir = Join-Path $toolsDir 'installer'

If (Get-ProcessorBits -eq 64){
	$packageArgs = @{
    	packageName = $packageName
    	fileType = 'exe'
    	file = "$installerDir\PacketTracer72_64bit_setup.exe"
    	silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
	}

Write-Host "Installing 64-bit version."
Install-ChocolateyInstallPackage @packageArgs
}
else {
	$packageArgs = @{
    	packageName = $packageName
    	fileType = 'exe'
    	file = "$installerDir\PacketTracer72_32bit_setup.exe"
    	silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
	}

Write-Host "Installing 32-bit version."
Install-ChocolateyInstallPackage @packageArgs
}
