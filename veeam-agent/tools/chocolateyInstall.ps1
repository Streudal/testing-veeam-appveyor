$ErrorActionPreference = 'Stop';
$PackageParameters = Get-PackageParameters

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$url 				 = 'https://download5.veeam.com/VeeamAgentWindows_2.1.0.423.zip'
$checksumZip         = 'A72921ED4C6A5A2D8F1D11C4B1BD855D45B07F5150D73C072F933C9283A54E4E0669331D36FEB73C4049E22E1C39CF0495C2BE6BA44F9B0457E33925E1CE0EA9'
$checksumTypeZip     = 'SHA512'

Import-Module -Name "$($toolsDir)\helpers.ps1"

$zipArgs = @{
	packageName    = $env:ChocolateyPackageName
	url            = $url
	unzipLocation  = $ENV:TMP
	checksum       = $checksumZip
	checksumType   = $checksumTypeZip
}

$packageArgs = @{
	packageName    = $env:ChocolateyPackageName
	fileType       = 'EXE'
	file           = "$($ENV:TMP)\VeeamAgentWindows_$($packageVersion).exe"
	silentArgs     = '/silent /accepteula'
	validExitCodes = @(0, 1000, 1101)
}

Install-ChocolateyZipPackage @zipArgs

Install-ChocolateyInstallPackage @packageArgs

if ($PackageParameters.NoAutostartHard) {
	Update-RegistryValue `
		-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" `
		-Name "Veeam.EndPoint.Tray.exe" `
        -Type Binary `
		-Value ([byte[]](0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) `
		-Message "Disable Veeam Agent Autostart"
} else {
	Update-RegistryValue `
        -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" `
        -Name "Veeam.EndPoint.Tray.exe" `
        -Type Binary `
		-Value ([byte[]](0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) `
		-Message "Default Veeam Agent Autostart"
}
	
if ($PackageParameters.CleanStartmenu) {
	Remove-FileItem `
		-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam\"
	Install-ChocolateyShortcut `
		-ShortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam Agent.lnk" `
		-TargetPath "C:\Program Files\Veeam\Endpoint Backup\Veeam.EndPoint.Tray.exe"
	Install-ChocolateyShortcut `
		-ShortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam File Level Restore.lnk" `
		-TargetPath "C:\Program Files\Veeam\Endpoint Backup\Veeam.EndPoint.FLR.exe"
}	
