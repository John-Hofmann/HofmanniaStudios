									#############################################################################################################################################
									#																																			#
									#														FileName	Build-WrappedScript.ps1													#
									#														Author		John Hofmann															#
									#														Version		0.0.1																	#
									#														Date		09/15/2020																#
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

.PARAMETER <Parameter-Name>
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
	http:\\google.com
	
.LINK
	The name of a related topic. The value appears on the line below the ".LINK" keyword and must be preceded by a comment symbol # or included in the comment block.
	Repeat the ".LINK" keyword for each related topic.
	This content appears in the Related Links section of the help topic.
	The "Link" keyword content can also include a Uniform Resource Identifier (URI) to an online version of the same help topic. The online version opens when you use the Online parameter of Get-Help. The URI must begin with "http" or "https".
	The HelpURI parameter of CmdletBinding supersedes this.

.COMPONENT
	The technology or feature that the function or script uses, or to which it is related. This content appears when the Get-Help command includes the Component parameter of Get-Help.

.COMPONENT
	Component

.ROLE
	The user role for the help topic. This content appears when the Get-Help command includes the Role parameter of Get-Help.

.ROLE
	Role

.FUNCTIONALITY
	The intended use of the function. This content appears when the Get-Help command includes the Functionality parameter of Get-Help.

.FUNCTIONALITY
	Functionality
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
