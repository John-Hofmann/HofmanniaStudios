#############################################################################################################################################
#																																			#
#														FileName	FileName																#
#														Author		John Hofmann															#
#														Version		0.0.1																	#
#														Date		MM/DD/YYYY																#
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
	#	[Parameter(Mandatory=[bool], Position=[naturalnumber], ParameterSetName=[string], ValueFromPipeline=[bool], ValueFromPipelineByPropertyName=[bool], ValueFromRemainingArguments=[bool], HelpMessage='Displays when a mandatory parameter value is missing')]
	#	[Alias([string[]])] #Establishes an alternate name for the parameter. There's no limit to the number of aliases that you can assign to a parameter
	#	[type]
	#	[AllowNull()] #Allows the value of a mandatory parameter to be $null
	#	[AllowEmptyString()] #Allows the value of a mandatory parameter to be an empty string ("")
	#	[AllowEmptyCollection()] #Allows the value of a mandatory parameter to be an empty collection @()
	#	[ValidateCount([naturalnumber], [naturalnumber])] #Specifies the minimum and maximum number of parameter values that a parameter accepts
	#	[ValidateLength([naturalnumber], [naturalnumber])] #Specifies the minimum and maximum number of characters in a parameter or variable value
	#	[ValidatePattern([regex])] #Specifies a regular expression that's compared to the parameter or variable value
	#	[ValidateRange([naturalnumber], [naturalnumber])] #Specifies a numeric range for the parameter or variable value
	#	[ValidateScript([scriptblock])] #Specifies a script that is used to validate a parameter or variable value. PowerShell pipes the value to the script, and generates an error if the script returns $false or if the script throws an exception
	#	[ValidateSet([array])] #Specifies a set of valid values for a parameter or variable and enables tab completion
	#	[ValidateNotNull()] #Specifies that the parameter value can't be $null
	#	[ValidateNotNullOrEmpty()] #Specifies that the parameter value can't be $null and can't be an empty string ("")
	#	[ValidateDrive('C', 'D', 'Variable', 'Function', etc...)] #Specifies that the parameter value must represent the path, that's referring to allowed drives only
	#Text displayed by Get-Help for this Parameter
	$ParameterName = 'defaultvalue',

	# Parameter help description
	[Parameter(Mandatory)]
	[ValidateSet('Fruits', 'Vegetables')]
	$Type,

	# Parameter help description
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
	
)

DynamicParam {

	[System.Management.Automation.RuntimeDefinedParameterDictionary]$paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

	if ((Get-Location).Path -eq 'C:\') {
		[Parameter]$parameterAttributes = [Parameter]::new()
		$parameterAttributes.HelpMessage = 'Displays when a mandatory parameter value is missing'
		$parameterAttributes.Mandatory = $false
		$parameterAttributes.ParameterSetName = 'SetName'
		$parameterAttributes.Position = 1
		$parameterAttributes.ValueFromPipeline = $false
		$parameterAttributes.ValueFromPipelineByPropertyName = $false
		$parameterAttributes.ValueFromRemainingArguments = $false
		[System.Management.Automation.RuntimeDefinedParameter]$DynamicParameter = [System.Management.Automation.RuntimeDefinedParameter]::new('DynamicParameter', [string], $parameterAttributes)
		$paramDictionary.Add('DynamicParameter', $DynamicParameter)
		Register-ArgumentCompleter -CommandName PowerShellNewFileTemplate.ps1 -ParameterName DynamicParameter -ScriptBlock { (Get-ChildItem -File).FullName }
	}

	return $paramDictionary
}

Begin {}

Process {
	
	if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
		$DynamicParameter #Commands that require confirmation if ComfirmPreference is equal to or below ConfirmImpact level
	}

	if ($PSCmdlet.ShouldContinue("Target", "Operation")) {
		$DynamicParameter.Value#Commands that always require confirmation
	}
	
}

End {}