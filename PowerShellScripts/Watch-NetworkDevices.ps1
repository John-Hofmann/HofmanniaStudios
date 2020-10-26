#############################################################################################################################################
#																																			#
#														FileName	Watch-NetworkDevices.ps1												#
#														Author		John Hofmann															#
#														Version		0.0.1																	#
#														Date		10/26/2020																#
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
#	10/26/2020		0.0.1		Initial Build																								#
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
	https://github.com/John-Hofmann/HofmanniaStudios
	
.LINK
	The name of a related topic. The value appears on the line below the ".LINK" keyword and must be preceded by a comment symbol # or included in the comment block.
	Repeat the ".LINK" keyword for each related topic.
	This content appears in the Related Links section of the help topic.
	The "Link" keyword content can also include a Uniform Resource Identifier (URI) to an online version of the same help topic. The online version opens when you use the Online parameter of Get-Help. The URI must begin with "http" or "https".
	The HelpURI parameter of CmdletBinding supersedes this.
#>


[CmdletBinding(HelpUri = 'https://github.com/John-Hofmann/HofmanniaStudios', PositionalBinding = $false)]
#[OutputType([type1], [type2], ParameterSetName=[string])] #Provides the value of the OutputType property of the System.Management.Automation.FunctionInfo object that the Get-Command cmdlet returns
Param (
	[Parameter(Mandatory, Position = 0, HelpMessage = 'Path to a CSV file containing the HostName, IPAddress, SerialNumber, Model, and Location of each device to be watched.')]
	[string]
	$File,

	[Parameter(Mandatory, HelpMessage = 'The mailrelay to use for sending alerts.')]
	[string]
	$MailRelay,

	[Parameter(Mandatory, HelpMessage = 'The email address(es) to receive alerts.')]
	[string[]]
	$To,

	[Parameter(Mandatory, HelpMessage = 'The email address to use for sending alerts.')]
	[string]
	$From
)
	
class Cursor {
	[void]savePosition() {
		[System.Console]::Write("$([char]27)7")
	}

	[void]restorePosition() {
		[System.Console]::Write("$([char]27)8")
	}

	[void]hide() {
		[System.Console]::Write("$([char]27)[?25l")
	}

	[void]show() {
		[System.Console]::Write("$([char]27)[?25h")
	}
}
	
class Text {
	[string]green([string]$s) {
		return "$([char]27)[92m" + $s + $this.default()
	}

	[string]yellow($s) {
		return "$([char]27)[93m" + $s + $this.default()
	}

	[string]red($s) {
		return "$([char]27)[91m" + $s + $this.default()
	}

	[string]default() {
		return "$([char]27)[0m"
	}
}

class Device {
	[string]$hostName
	[string]$ipAddress
	[string]$model
	[string]$serialNumber
	[string]$location
	[string]$status
	[System.Threading.Tasks.Task]$pingReply
	[int]$count = 0
	[bool]$mailSent = $false
	[System.Net.NetworkInformation.Ping]$pinger = [System.Net.NetworkInformation.Ping]::new()

	[void]ping() {
		$this.pingReply = $this.pinger.SendPingAsync($this.ipAddress)
	}

	[void]update() {
		$this.status = $this.pingReply.Result.Status
		if ($this.status -eq 'Success') {
			$this.count = 0
		} else {
			$this.count++
		}
	}
}

[System.Net.Mail.MailMessage]$mailMessage = [System.Net.Mail.MailMessage]::new()
[System.Net.Mail.SmtpClient]$smtpClient = [System.Net.Mail.SmtpClient]::new($MailRelay)
$mailMessage.From = $From

foreach ($address in $To) {
	$mailMessage.To.Add($address)
}

[int]$hostNamePadding = 8
[int]$ipAddressPadding = 12
[int]$serialNumberPadding = 12
[int]$modelPadding = 5
[int]$locationPadding = 8
[int]$statusPadding = 26

[Cursor]$cursor = [Cursor]::new()
[Text]$text = [Text]::new()

[System.Collections.Generic.List[Device]]$deviceList = [System.Collections.Generic.List[Device]]::new()
$PSCmdlet.WriteDebug("Importing " + $File + "...")
Import-Csv -Path $File | ForEach-Object {
	$PSCmdlet.WriteDebug('[Device]$d = ' + "$_")
	[Device]$d = $_
	$PSCmdlet.WriteDebug('$deviceList.Add(' + "$d" + ')')
	$deviceList.Add($d)
}

foreach ($device in $deviceList) {
	if ($device.hostName.Length -gt $hostNamePadding) {
		$hostNamePadding = $device.hostName.Length
	}
	
	if ($device.serialNumber.Length -gt $serialNumberPadding) {
		$serialNumberPadding = $device.serialNumber.Length
	}
		
	if ($device.model.Length -gt $modelPadding) {
		$modelPadding = $device.model.Length
	}
		
	if ($device.location.Length -gt $locationPadding) {
		$locationPadding = $device.location.Length
	}		
}

[System.Console]::WriteLine(("{0,-$hostNamePadding}" -f 'Hostname') + "`t" + ("{0,-$ipAddressPadding}" -f 'IPAddress') + "`t" + ("{0,-$serialNumberPadding}" -f 'SerialNumber') + "`t" + ("{0,-$modelPadding}" -f 'Model') + "`t" + ("{0,-$locationPadding}" -f 'Location') + "`tStatus")

$cursor.savePosition()
$cursor.hide()

while ($true) {
	foreach ($device in $deviceList) {
		$device.ping()
		$device.update()

		if ($device.status -eq 'Success') {
			#[System.Console]::WriteLine($device.location + ' ' + $device.model + ' ' + $device.serialNumber + ' ' + $device.hostName + ' ' + $device.ipAddress + ' ' + $text.green("{0,-26}" -f $device.status))
			[System.Console]::WriteLine(("{0,-$hostNamePadding}" -f $device.hostName) + "`t" + ("{0,-$ipAddressPadding}" -f $device.ipAddress) + "`t" + ("{0,-$serialNumberPadding}" -f $device.serialNumber) + "`t" + ("{0,-$modelPadding}" -f $device.model) + "`t" + ("{0,-$locationPadding}" -f $device.location) + "`t" + $text.green("{0,-$statusPadding}" -f $device.status))
			$device.mailSent = $false
		} elseif ($device.count -ge 4) {
			#[System.Console]::WriteLine($device.location + ' ' + $device.model + ' ' + $device.serialNumber + ' ' + $device.hostName + ' ' + $device.ipAddress + ' ' + $text.red("{0,-26}" -f $device.status))
			[System.Console]::WriteLine(("{0,-$hostNamePadding}" -f $device.hostName) + "`t" + ("{0,-$ipAddressPadding}" -f $device.ipAddress) + "`t" + ("{0,-$serialNumberPadding}" -f $device.serialNumber) + "`t" + ("{0,-$modelPadding}" -f $device.model) + "`t" + ("{0,-$locationPadding}" -f $device.location) + "`t" + $text.red("{0,-$statusPadding}" -f $device.status))
			if (!$device.mailSent) {
				$mailMessage.Subject = $device.hostName + ' is down!'
				$mailMessage.Body = $device.hostName + ' went down at ' + [datetime]::Now
				$smtpClient.Send($mailMessage)
				$PSCmdlet.WriteVerbose("Sending Mail at " + [datetime]::Now)
				$device.mailSent = $true
			}
		} else {
			#[System.Console]::WriteLine($device.location + ' ' + $device.model + ' ' + $device.serialNumber + ' ' + $device.hostName + ' ' + $device.ipAddress + ' ' + $text.yellow("{0,-26}" -f $device.status))
			[System.Console]::WriteLine(("{0,-$hostNamePadding}" -f $device.hostName) + "`t" + ("{0,-$ipAddressPadding}" -f $device.ipAddress) + "`t" + ("{0,-$serialNumberPadding}" -f $device.serialNumber) + "`t" + ("{0,-$modelPadding}" -f $device.model) + "`t" + ("{0,-$locationPadding}" -f $device.location) + "`t" + $text.yellow("{0,-$statusPadding}" -f $device.status))
		}
	}

	$cursor.restorePosition()
}
	