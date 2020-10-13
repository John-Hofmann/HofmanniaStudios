#############################################################################################################################################
#																																			#
#														FileName	Get-PackageFiles.ps1													#
#														Author		John Hofmann															#
#														Version		0.2.0																	#
#														Date		10/13/2020																#
#																																			#
#											Copyright © 2020 John Hofmann All Rights Reserved												#
#											https://github.com/John-Hofmann/HofmanniaStudios												#
#																																			#
#									This program is free software: you can redistribute it and/or modify									#
#									it under the terms of the GNU General Public License as published by									#
#										the Free Software Foundation, either version 3 of the License, or									#
#													(at your option) any later version.														#
#																																			#
#										This program is distributed in the hope that it will be useful,										#
#										but WITHOUT ANY WARRANTY; without even the implied warranty of										#
#										MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the										#
#												GNU General Public License for more details.												#
#																																			#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#															Changelog																		#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#	Date			Version		Notes																										#
#	──────────		───────		─────────────────────────────────────────────────────────────────────────────────────────────────────────── #
#	10/08/2020		0.0.1		Initial Build																								#
#	10/09/2020		0.0.2		Updated downloading logic to account for packages that contain more than one distribution package			#
#	10/12/2020		0.1.0		Implemented Credential parameter for providing alternate credentials to access SCCMContentLibRootPath		#
#	10/13/2020		0.2.0		Added System.Management.Automation.Credential() transformation to Credential parameter						#
#								Populated Comment-based Help blocks																			#
#																																			#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#														  Known Issues																		#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#	None																																	#
#																																			#
#############################################################################################################################################

<#
.SYNOPSIS
	Downloads the contents of an SCCM package.

.DESCRIPTION
	The Get-PackageFiles cmdlet enumerates the files of each ContentID contained within the specified SCCM PackageID, and downloads the files.

	First the PackageID.INI file for the specified package in the Package library is parsed, building a list of all ContentIDs in that package.

	Then the Data library folder for each ContentID is located, and the INI files contained within are used to build a list of source and destination files.

	Finally, the source files are downloaded from the File library to the destination.

.EXAMPLE
	.\Get-PackageFiles.ps1 -SCCMContentLibRootPath \\sccmdp.mydomain.com\e$\SCCMContentLib -PackageID C0000001

	Downloading File1.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\0123\0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
	Destination: .\C0000001\C0000001.1\File1.exe

	Downloading File2.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\1234\123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0
	Destination: .\C0000001\C0000001.1\File2.exe

	Downloading File1.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\2345\23456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01
	Destination: .\C0000001\C0000001.2\File1.exe

	Downloading File2.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\3456\3456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF012
	Destination: .\C0000001\C0000001.2\File2.exe


	The above command downloads all files in each ContentID of C0000001 to subdirectories under .\C0000001\	

.EXAMPLE
	.\Get-PackageFiles.ps1 -SCCMContentLibRootPath \\sccmdp.mydomain.com\e$\SCCMContentLib -PackageID C0000001 -Destination C:\Windows\Temp -Credential mydomain\myusername

	Downloading File1.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\0123\0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
	Destination: C:\Windows\Temp\C0000001\C0000001.1\File1.exe

	Downloading File2.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\1234\123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0
	Destination: C:\Windows\Temp\C0000001\C0000001.1\File2.exe

	Downloading File1.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\2345\23456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01
	Destination: C:\Windows\Temp\C0000001\C0000001.2\File1.exe

	Downloading File2.exe...
	Source: \\sccmdp.mydomain.com\e$\SCCMContentLib\FileLib\3456\3456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF012
	Destination: C:\Windows\Temp\C0000001\C0000001.2\File2.exe


	The above command is the same as example 1, but downloads the files to C:\Windows\Temp, and provides Credentials for accessing the SCCM Content library root

.INPUTS
	None
		You cannot pipe input to this cmdlet.

.OUTPUTS
	None
		This cmdlet does not return any objects.

.NOTES


.LINK
	https://github.com/John-Hofmann/HofmanniaStudios
#>


[CmdletBinding(ConfirmImpact = [System.Management.Automation.ConfirmImpact]::Medium, <#DefaultParameterSetName=[string], #>HelpUri = 'https://github.com/John-Hofmann/HofmanniaStudios', SupportsPaging = $false, SupportsShouldProcess = $true, PositionalBinding = $false)]
#[OutputType([type1], [type2], ParameterSetName=[string])] #Provides the value of the OutputType property of the System.Management.Automation.FunctionInfo object that the Get-Command cmdlet returns
Param (
	#The path to the SCCM Content library root directory where the Data library, File library, and Package library are located.
	[Parameter(Mandatory, Position = 0, HelpMessage = 'The path to the SCCMContentLib root directory')]
	[Alias('Root')]
	[string]
	[ValidateNotNullOrEmpty()]
	$SCCMContentLibRootPath,
	
	#The PackageID of the package that you want to download.
	[Parameter(Mandatory, Position = 1, HelpMessage = 'The PackageID of the Package to download')]
	[Alias('ID')]
	[string]
	[ValidatePattern('^[0-9A-F]{8}$')]
	$PackageID,

	#The path to the destination folder that you want the files downloaded to. If this parameter is omitted, the files are downloaded to the current working directory.
	[Parameter()]
	[string]
	[ValidateNotNullOrEmpty()]
	$Destination = "$env:windir\ccmcache",

	#Credentials with access to the SCCM Content library root.
	[Parameter()]
	[pscredential]
	[System.Management.Automation.Credential()]
	$Credential	
)

Begin {

	[string]$workingDirectory = ''
	if ($PWD.Provider.Name -eq 'FileSystem') {
		$PSCmdlet.WriteDebug('Setting .NET CurrentDirectory')
		$workingDirectory = $PWD.Path
	} else {
		$workingDirectory = $env:USERPROFILE
	}

	[System.IO.Directory]::SetCurrentDirectory($workingDirectory)

	if ($Credential) {
		New-PSDrive -Name SCCMContentLibRootPath -PSProvider FileSystem -Root $SCCMContentLibRootPath -Scope 0 -Credential $Credential
	}

	if (![System.IO.Directory]::Exists($SCCMContentLibRootPath)) {
		[System.IO.IOException]$IOException = "The path '$SCCMContentLibRootPath' does not exist, or you do not have access to it."
		[System.Management.Automation.ErrorRecord]$errorRecord = [System.Management.Automation.ErrorRecord]::new($IOException, 'SCCMContentLibRootPathNotFound,HofmanniaStudios.Commands.GetPackageFiles', 'ObjectNotFound', $SCCMContentLibRootPath)
		$PSCmdlet.ThrowTerminatingError($errorRecord)
	}

	function Get-IniContent {
		param (
			[string]$filePath
		)

		[hashtable]$iniObject = @{}

		switch -regex -file $filePath {

			'\[(.+)\]' {
				[string]$section = $Matches[1]
				$iniObject.Add($section, @{})
			}

			'(\S+?)\s*=\s*(.*?)\s*$' {
				[string]$name = $Matches[1]
				[string]$value = $Matches[2]
				$iniObject.$section.Add($name, $value)
			}

			Default {}

		}

		return $iniObject
		
	}

	[System.Console]::WriteLine('')

}

Process {

	$Destination += "\$PackageID"
	[string]$packageINI = "$SCCMContentLibRootPath\PkgLib\$PackageID.INI"

	if (![System.IO.File]::Exists($packageINI)) {
		[System.IO.IOException]$IOException = "The file '$packageINI' does not exist. Verify that the SCCMContentLibRootPath and PackageID are valid."
		[System.Management.Automation.ErrorRecord]$errorRecord = [System.Management.Automation.ErrorRecord]::new($IOException, 'PackageFileNotFound,HofmanniaStudios.Commands.GetPackageFiles', 'ObjectNotFound', $packageINI)
		$PSCmdlet.WriteError($errorRecord)
		return
	}

	[hashtable]$packageINIContents = Get-IniContent -filePath $packageINI

	foreach ($contentID in $packageINIContents.Packages.Keys) {
		[string]$contentIDDirectory = "$SCCMContentLibRootPath\DataLib\$contentID"
		[string[]]$contentINIs = [System.IO.Directory]::EnumerateFiles($contentIDDirectory, '*', 'AllDirectories')

		foreach ($fileINI in $contentINIs) {
			[hashtable]$fileINIContents = Get-IniContent -filePath $fileINI
			[string]$hashedFileName = $fileINIContents.File.Hash
			[string]$sourceDirectory = "$SCCMContentLibRootPath\FileLib\" + $hashedFileName.Substring(0, 4)
			[string]$sourcePath = "$sourceDirectory\$hashedFileName"
			[string]$destinationDirectory = [System.IO.Path]::GetDirectoryName($fileINI)
			[string]$destinationDirectory = $destinationDirectory.Replace($contentIDDirectory, "$Destination\$contentID")

			if ($PSCmdlet.ShouldProcess($destinationDirectory, 'Create Directory')) {
				if (![System.IO.Directory]::Exists($destinationDirectory)) {
					[void][System.IO.Directory]::CreateDirectory($destinationDirectory)
				}
			}

			[string]$destianationFileName = $fileINI -replace '^.*\\(.*).INI$', '$1'
			[string]$destinationPath = "$destinationDirectory\$destianationFileName"

			if ($PSCmdlet.ShouldProcess($destinationPath, 'Create File')) {
				[System.Console]::WriteLine('Downloading ' + $destianationFileName + '...')
				[System.Console]::WriteLine('Source: ' + $sourcePath)
				[System.Console]::WriteLine('Destination: ' + $destinationPath)
				[System.Console]::WriteLine('')

				[System.IO.File]::Copy($sourcePath, $destinationPath)
			}
		}
	}
	
}

End {}