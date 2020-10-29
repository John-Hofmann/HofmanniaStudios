::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::																																			::
::														FileName	FileName																::
::														Author		John Hofmann															::
::														Version		0.0.1																	::
::														Date		MM/DD/YYYY																::
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
::	MM/DD/YYYY		0.0.1		Initial Build																								::
::																																			::
::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
::														  Known Issues																		::
::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
::	None																																	::
::																																			::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::Desciption
::	Description of script.
::
::Parameters
::	Script parameters.
::	-h, -?, --help
::		Displays help for the script.
::
::Exit Codes
::	0  --  'SUCCESS'
::	968 -- 'HELPDISPLAYED'
::	1582 - 'UNRECOGNIZEDPARAMETER'

@echo off
:parameters
	set "param=%1"
	set "shift=0"
	set "helpResult="
	call :help -h -? --help
	%helpResult%

	if %shift% neq 0 (
		shift /%shift%
	) else (
		if "%1" neq "" (
			echo:Unrecognized parameter "%1" >&2
			echo:-h, --help, or -? can be used to display help. >&2
			exit /b 1582
		)
	)

	if "%1" neq "" (
		goto :parameters
	)

:script
	::<script goes here>:: 														NewWindowsCommandScript.cmd Version 1.0.0
exit /b 0

:functions
	:help
		if /i "%param%" equ "%1" (
			goto:helptext
		) else (
			if /i "%param%" equ "/?" (
				goto:helptext
			)
		)
		shift
		if "%1" neq "" goto :help
		exit /b 0
		:helptext
		echo:This is some help text.
		set "helpResult=exit /b 968"
	exit /b 968