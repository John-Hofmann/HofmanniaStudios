﻿#############################################################################################################################################
#																																			#
#														FileName	Get-Input.ps1															#
#														Author		John Hofmann															#
#														Version		1.0.0																	#
#														Date		09/29/2020																#
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
#	09/25/2020		0.0.1		Initial Build																								#
#	09/28/2020		0.1.0		Added an optional Title parameter to add text to the Title bar of the window								#
#	09/28/2020		0.2.0		Added an optional TrimWhitespace parameter to remove whitespace from the beginning and end of the input		#
#	09/29/2020		0.3.0		Removed default max character limit of 32767																#
#								Enabled shortcuts 																							#
#										(https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.textboxbase.shortcutsenabled)		#
#								Disabled wordwrap																							#
#								Improved return methods to clear up some issues with blank lines											#
#	09/29/2020		1.0.0		Initial Release Version																						#
#								Added drag and drop functionality to the textbox															#
#								Form explicitly activates when shown, resolving occasional bug where form was not activating at creation	#
#								Updated comments																							#
#								Added the ability to double click the textbox to select all text											#
#								Added mnemonic keys to Ok and Cancel buttons																#
#																																			#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#														  Known Issues																		#
#═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════#
#	None																																	#
#																																			#
#############################################################################################################################################

<#
.SYNOPSIS
	Prompts the user for multiple lines of input, and outputs them to the pipeline.

.DESCRIPTION
	Presents a form with a multi-line textbox for user input. The input is then split by LF and output to the pipeline.

.EXAMPLE
	.\Get-Input.ps1 | Get-ADUser

	Each username entered into the textbox would be piped out to Get-ADUser.

.EXAMPLE
	.\Get-Input.ps1 -Title "Enter a list of usernames" | Get-ADUser

	The same as Example 1, but "Enter a list of usernames" will be displayed in the Title bar.

.EXAMPLE
	.\Get-Input.ps1 -TrimWhitespace

	Sample Input:
		|This line has no leading or trailing whitespace|
		|  This line has leading whitespace|
		|This line has trailing whitespace |
		|	This line has leading and trailing whitespace	|

	Output:
		|This line has no leading or trailing whitespace|
		|This line has leading whitespace|
		|This line has trailing whitespace|
		|This line has leading and trailing whitespace|

		Note that the | characters denote the beginning and ending of the line for
		visual purposes, and are not part of the Input or Output.

.INPUTS
	System.Windows.Forms.DataObject
		You can drag files or text onto the textbox to add the text or file contents to the textbox.

.OUTPUTS
	System.String or System.String[]
		The line(s) of text entered into the textbox.

.NOTES
	

.LINK
	https://github.com/John-Hofmann/HofmanniaStudios
#>


[CmdletBinding(<#DefaultParameterSetName=[string], HelpUri = 'https://www.google.com', PositionalBinding = $false, #>)]
[OutputType([string[]], [string])] #Provides the value of the OutputType property of the System.Management.Automation.FunctionInfo object that the Get-Command cmdlet returns
Param (
	#The text to be displayed in the Title bar of the window.
	[Parameter()]
	[string]
	$Title,

	#Removes beginning and ending whitespace from the input before returning it.
	[Parameter()]
	[switch]
	$TrimWhitespace
)

Process {

	#In 100,000 trials, this code was 3 times faster than the built in Add-Type Cmdlet, so I'm using it here.
	function Add-Type {
		param (
			[string]$AssemblyName
		)
	
		[string[]]$assemblyInfo = [System.IO.Directory]::EnumerateDirectories("$env:windir\Microsoft.NET\assembly\GAC_MSIL\$AssemblyName") -replace '.*v4.0_', '' -replace '__', '_' -split '_'
		[string]$fullName = "$AssemblyName, Version=$($assemblyInfo[0]), Culture=neutral, PublicKeyToken=$($assemblyInfo[1])"
		[void][System.Reflection.Assembly]::Load($fullName)
	}

	Add-Type -AssemblyName System.Drawing
	Add-Type -AssemblyName System.Windows.Forms
	
	[System.Windows.Forms.Application]::EnableVisualStyles()

	#Creating the form body
	[System.Windows.Forms.Form]$form = [System.Windows.Forms.Form]::new()
	$form.AutoSize = $true
	$form.FormBorderStyle = 'FixedSingle'
	$form.StartPosition = "CenterScreen"
	if ($Title) { $form.Text = $Title }
	$form.TopMost = $true

	#Defining events for the form body
	$form.Add_Shown( {
			$form.Activate()
		})
	
	#Creating the input textbox
	[System.Windows.Forms.TextBox]$textBox = [System.Windows.Forms.TextBox]::new()
	$textBox.AcceptsReturn = $true
	$textBox.AllowDrop = $true
	$textBox.MaxLength = 0
	$textBox.Multiline = $true
	$textBox.ScrollBars = 'Both'
	$textBox.ShortcutsEnabled = $true
	$textBox.Size = [System.Drawing.Size]::new(575, 240)
	$textBox.WordWrap = $false

	#Defining events for the textbox
	$textBox.Add_DoubleClick( {
			$textBox.SelectAll()
		})

	$textBox.Add_DragDrop( {
			if ($_.Data.GetDataPresent('FileDrop')) {
				$_.Data.GetData('FileDrop') | ForEach-Object {
					$textBox.AppendText([System.IO.File]::ReadAllText($_))
				}
			} elseif ($_.Data.GetDataPresent('Text')) {
				$textBox.AppendText($_.Data.GetData('Text'))
			}
		})

	$textBox.Add_DragEnter( {
			$_.Effect = 'Copy'
		})

	#Creating the Ok button
	[System.Windows.Forms.Button]$okButton = [System.Windows.Forms.Button]::new()
	$okButton.Location = [System.Drawing.Size]::new(415, 250)
	$okButton.Text = "&Ok"

	#Defining events for the Ok button
	$okButton.Add_Click(
		{
			$form.Close()
		}
	)
	
	#Creating the Cancel button
	[System.Windows.Forms.Button]$cancelButton = [System.Windows.Forms.Button]::new()
	$cancelButton.Location = [System.Drawing.Size]::new(495, 250)
	$cancelButton.Text = "&Cancel"

	#Defining events for the Cancel button
	$cancelButton.Add_Click(
		{
			$textBox.Text = $null
			$form.Close()
		}
	)
	
	#Adding the controls to the form
	$form.Controls.Add($textBox)
	$form.Controls.Add($okButton)
	$form.Controls.Add($cancelButton)
	$form.ActiveControl = $textBox
	$form.CancelButton = $cancelButton

	#Showing the form interactively
	[void]$form.ShowDialog()
	if (!$TrimWhitespace) {
		return $textBox.Lines
	} else {
		$textBox.Text = $textBox.Text -replace "\s*\r\n\s*", "`n" -replace "^\n\s*", '' -replace "\n\s*$", ''
		return $textBox.Lines -replace "^\s*", "" -replace "\s*$", ""
	}
}
