									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									::																																			::
									::														FileName	PowerShellWrapper.cmd													::
									::														Author		John Hofmann															::
									::														Version		0.1.0																	::
									::														Date		09/14/2020																::
									::																																			::
									::											Copyright © 2020 John Hofmann All Rights Reserved												::
									::											https://github.com/John-Hofmann/HofmanniaStudios												::
									::																																			::
									::									This program is free software: you can redistribute it and/or modify									::
									::									it under the terms of the GNU General Public License as published by									::
									::										the Free Software Foundation, either version 3 of the License, or									::
									::													(at your option) any later version.														::
									::																																			::
									::										This program is distributed in the hope that it will be useful,										::
									::										but WITHOUT ANY WARRANTY; without even the implied warranty of										::
									::										MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the										::
									::												GNU General Public License for more details.												::
									::																																			::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::															Changelog																		::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::	Date			Version		Notes																										::
									::	──────────		───────		─────────────────────────────────────────────────────────────────────────────────────────────────────────── ::
									::	09/14/2020		0.0.1		Initial Build																								::
									::	09/15/2020		0.0.2		Updated ownership info to new style																			::
									::	09/16/2020		0.1.0		Added GPL3 License boilerplate																				::
									::																																			::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::														  Known Issues																		::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::	None																																	::
									::																																			::
									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									
@ECHO OFF
START "%~nx0" /D "%ALLUSERSPROFILE%" /WAIT /B PowerShell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command $codeStart = (Select-String -Pattern '^^:PowerShell Code Start' -Path '%~f0').LineNumber; $lineCount = (Get-Content '%~f0').Length - $codeStart; Get-Content '%~f0' -Last $lineCount ^| ForEach-Object {$commands += \"$_`n\"}; $scriptBlock = [scriptblock]::Create($commands); Invoke-Command $scriptBlock
EXIT /B %ERRORLEVEL%

:PowerShell Code Start
#Sample Code
'Success!' | Write-Host -ForegroundColor Green
Read-Host
Exit 7
