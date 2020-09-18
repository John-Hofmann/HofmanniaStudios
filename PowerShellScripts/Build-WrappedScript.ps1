									#############################################################################################################################################
									#																																			#
									#														FileName	Build-WrappedScript.ps1													#
									#														Author		John Hofmann															#
									#														Version		1.0.0																	#
									#														Date		09/18/2020																#
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
									#	09/15/2020		0.0.1		Initial Build																								#
									#	09/18/2020		1.0.0		Initial Release Version																						#
									#																																			#
									#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
									#														  Known Issues																		#
									#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
									#	None																																	#
									#																																			#
									#############################################################################################################################################

<#
.SYNOPSIS
	Wraps a .ps1 file in a .cmd file for ease of execution.

.DESCRIPTION
	The Build-WrappedScript cmdlet wraps the contents of a .ps1 file in a .cmd file to enable double click execution.

	The InputScript parameter identifies the source .ps1 file. You can also pass a string object through the pipeline to the InputScript parameter to enable processing multiple .ps1 files at once.

	The resulting .cmd file will be created in the current PowerShell working directory, or the User Profile directory if the current working directory is not a FileSystem directory. It will have the same file name as the source .ps1 file, but with a .cmd extension instead of .ps1.

.PARAMETER InputScript
	The existing .ps1 script to be wrapped.

.PARAMETER Force
	Forces this cmdlet to create a .cmd file that overwrites and existing .cmd file. By default, this cmdlet fails if the destination file already exists.

.EXAMPLE
	.\Build-WrappedScript.ps1 -InputScript Foo.ps1

	Creates Foo.cmd file containing the wrapped code from Foo.ps1 in the current directory.

	Will write an error and fail if Foo.cmd already exists.

.EXAMPLE
	.\Build-WrappedScript.ps1 Foo.ps1

	The same as Example 1. The InputScript parameter is positional and does not have to be named.

.EXAMPLE
	.\Build-WrappedScript.ps1 Foo.ps1 -Force

	Creates Foo.cmd file containing the wrapped code from Foo.ps1 in the current directory.

	This will overwrite an existing Foo.cmd

.EXAMPLE
	'Foo.ps1','Bar.ps1' | .\Build-WrappedScript.ps1

	Uses piped input to wrap multiple .ps1 files.

	The InputScript parameter accepts values from the pipeline, allowing you to wrap multiple .ps1 files at once.

.INPUTS
	System.String
		You can pipe a value for the InputScript to this cmdlet.

.OUTPUTS
	None

.NOTES
	This cmdlet is only designed to work with scripts that do not require parameters, to allow ease of execution by double clicking. Scripts with parameters would require the user to enter a command line anyway, so wrapping them would not serve much purpose.

	If you feel there is a meaningful use case for wrapping parameterized scripts, please contact me, and I will look into it.

.LINK
	https://github.com/John-Hofmann/HofmanniaStudios/blob/master/PowerShellScripts/Build-WrappedScript.ps1
	
#>


[CmdletBinding(ConfirmImpact='Medium', PositionalBinding=$false, SupportsShouldProcess)]

Param (
	[Parameter(HelpMessage='The path of the .ps1 file to wrap.', Mandatory, Position=0, ValueFromPipeline)]
	[string]
	$InputScript,

	[Parameter()]
	[switch]
	$Force
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

}

Process{
	
	if ($InputScript -notmatch '.ps1$') {
		[System.IO.IOException]$IOException = "The file '$InputScript' is not a valid .ps1 file."
		[System.Management.Automation.ErrorRecord]$errorRecord = [System.Management.Automation.ErrorRecord]::new($IOException, 'NotValidInputFile,HofmanniaStudios.Commands.BuildWrappedScript', 'InvalidData', $InputScript)
		$PSCmdlet.WriteError($errorRecord)
		return
	}

	try {
		[string[]]$sourceCode = [System.IO.File]::ReadAllLines($InputScript)
	} catch {
		$PSCmdlet.WriteError($_)
		return
	}

	[string]$destination = $workingDirectory + '\' + ($InputScript -replace '.*\\','' -replace '\.ps1','.cmd')

	if ($PSCmdlet.ShouldProcess($destination, 'Create File')) {
		if (![System.IO.File]::Exists($destination) -or $Force) {
			[string[]]$wrappedCode ='@ECHO OFF'
			$wrappedCode += 'START "%~nx0" /D "%ALLUSERSPROFILE%" /WAIT /B PowerShell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command $codeStart = (Select-String -Pattern ''^^:PowerShell Code Start'' -Path ''%~f0'').LineNumber; $lineCount = (Get-Content ''%~f0'').Length - $codeStart; Get-Content ''%~f0'' -Last $lineCount ^| ForEach-Object {$commands += \"$_`n\"}; $scriptBlock = [scriptblock]::Create($commands); Invoke-Command $scriptBlock'
			$wrappedCode += 'EXIT /B %ERRORLEVEL%'
			$wrappedCode += "`n"
			$wrappedCode += ':PowerShell Code Start'
			$wrappedCode += $sourceCode
			[System.IO.File]::WriteAllLines($destination, $wrappedCode)
		} else {
			[System.IO.IOException]$IOException = "The file '$destination' already exists."
			[System.Management.Automation.ErrorRecord]$errorRecord = [System.Management.Automation.ErrorRecord]::new($IOException, 'FileExists,HofmanniaStudios.Commands.BuildWrappedScript', 'WriteError', $destination)
			$PSCmdlet.WriteError($errorRecord)
			return
		}
	}
}
