#############################################################################################################################################
#																																			#
#														FileName	Get-PackageFiles.ps1													#
#														Author		John Hofmann															#
#														Version		0.0.2																	#
#														Date		10/09/2020																#
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
#	MM/DD/YYYY		0.0.1		Initial Build																								#
#	MM/DD/YYYY		0.0.2		Updated downloading logic to account for packages that contain more than one distribution package			#
#																																			#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#														  Known Issues																		#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#	None																																	#
#																																			#
#############################################################################################################################################

<#
.SYNOPSIS
	A brief description of the function or script. This keyword can be used only once in each topic.

.DESCRIPTION
	A detailed description of the function or script. This keyword can be used only once in each topic.

.PARAMETER ParameterName
	The description of a parameter. Add a ".PARAMETER" keyword for each parameter in the function or script syntax.

	Type the parameter name on the same line as the ".PARAMETER" keyword. Type the parameter description on the lines following the ".PARAMETER" keyword. Windows PowerShell interprets all text between the ".PARAMETER" line and the next keyword or the end of the comment block as part of the parameter description. The description can include paragraph breaks.

.PARAMETER ParameterName
	The Parameter keywords can appear in any order in the comment block, but the function or script syntax determines the order in which the parameters (and their descriptions) appear in help topic. To change the order, change the syntax.

	You can also specify a parameter description by placing a comment in the function or script syntax immediately before the parameter variable name. If you use both a syntax comment and a Parameter keyword, the description associated with the Parameter keyword is used, and the syntax comment is ignored.

.EXAMPLE
	Example.ps1

	A sample command that uses the function or script, optionally followed by sample output and a description. Repeat this keyword for each example.

.INPUTS
	The Microsoft .NET Framework types of objects that can be piped to the function or script. You can also include a description of the input objects.

.OUTPUTS
	The .NET Framework type of the objects that the cmdlet returns. You can also include a description of the returned objects.

.NOTES
	Additional information about the function or script.

.LINK
	https://google.com
	
.LINK
	The name of a related topic. The value appears on the line below the ".LINK" keyword and must be preceded by a comment symbol # or included in the comment block.
	Repeat the ".LINK" keyword for each related topic.
	This content appears in the Related Links section of the help topic.
	The "Link" keyword content can also include a Uniform Resource Identifier (URI) to an online version of the same help topic. The online version opens when you use the Online parameter of Get-Help. The URI must begin with "http" or "https".
	The HelpURI parameter of CmdletBinding supersedes this.
#>


[CmdletBinding(ConfirmImpact = [System.Management.Automation.ConfirmImpact]::Medium, <#DefaultParameterSetName=[string], #>HelpUri = 'https://www.google.com', SupportsPaging = $false, SupportsShouldProcess = $true, PositionalBinding = $false)]
#[OutputType([type1], [type2], ParameterSetName=[string])] #Provides the value of the OutputType property of the System.Management.Automation.FunctionInfo object that the Get-Command cmdlet returns
Param (
	# Parameter help description
	[Parameter(Mandatory, Position = 0, HelpMessage = 'The path to the SCCMContentLib root directory')]
	[Alias('Root')]
	[string]
	[ValidateNotNullOrEmpty()]
	$SCCMContentLibRootPath,
	
	# Parameter help description
	[Parameter(Mandatory, Position = 1, HelpMessage = 'The PackageID of the Package to download')]
	[Alias('ID')]
	[string]
	[ValidatePattern('^[0-9A-F]{8}$')]
	$PackageID,

	# Parameter help description
	[Parameter()]
	[string]
	[ValidateNotNullOrEmpty()]
	$Destination = "$env:windir\ccmcache",

	# Parameter help description
	[Parameter()]
	[pscredential]
	$Credential

	
	<#
	[Parameter(Mandatory)]
	[ArgumentCompleter( {
			param ($commandName, $ParameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

			$possibleValues = @{
				Fruits     = @('Apple', 'Orange', 'Banana')
				Vegetables = @('Tomato', 'Squash', 'Corn')
			}

			if ($fakeBoundParameters.ContainsKey('Type')) {
				$possibleValues[$fakeBoundParameters.Type] | Where-Object {
					$_ -like "$wordToComplete*"
				}
			} else {
				$possibleValues.Values | ForEach-Object {
					$_
				}
			}
		})]
	$Value
	#>
	
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

	foreach ($package in $packageINIContents.Packages.Keys) {
		[string]$dataLibDirectory = "$SCCMContentLibRootPath\DataLib\$package"
		[string[]]$packageFileINIs = [System.IO.Directory]::EnumerateFiles($dataLibDirectory, '*', 'AllDirectories')

		foreach ($file in $packageFileINIs) {
			[hashtable]$packageFileINIContents = Get-IniContent -filePath $file
			[string]$hashedFileName = $packageFileINIContents.File.Hash
			[string]$fileLibDirectory = "$SCCMContentLibRootPath\FileLib\" + $hashedFileName.Substring(0, 4)
			[string]$sourcePath = "$fileLibDirectory\$hashedFileName"
			[string]$destinationDirectory = [System.IO.Path]::GetDirectoryName($file)
			[string]$destinationDirectory = $destinationDirectory.Replace($dataLibDirectory, "$Destination\$package")

			if ($PSCmdlet.ShouldProcess($destinationDirectory, 'Create Directory')) {
				if (![System.IO.Directory]::Exists($destinationDirectory)) {
					[void][System.IO.Directory]::CreateDirectory($destinationDirectory)
				}
			}

			[string]$destianationFileName = $file -replace '^.*\\(.*).INI$', '$1'
			[string]$destinationPath = "$destinationDirectory\$destianationFileName"

			if ($PSCmdlet.ShouldProcess($destinationPath, 'Create File')) {
				'Downloading ' + $destianationFileName + '...'
				'Source: ' + $sourcePath
				'Destination: ' + $destinationPath
				''

				[System.IO.File]::Copy($sourcePath, $destinationPath)
			}
		}
	}
	
}

End {}