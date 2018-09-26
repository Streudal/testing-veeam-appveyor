$ErrorActionPreference = 'Stop';
$PackageParameters = Get-PackageParameters

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$url 				 = 'https://download5.veeam.com/VeeamAgentWindows_2.1.0.423.zip'
$checksumZip         = '8D090F64C5F7EE5927E674E9ACC0CEE9382BA05A98E98CEB7ECE8E10DA0953EC09F2A9301F9C7FB25C81F1874D8F55494521A3FA3863D2E721BDEF3B5F04BC17'
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
