									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									::																																			::
									::														FileName	HELP.cmd																::
									::														Author		John Hofmann															::
									::														Version		1.0.0																	::
									::														Date		09/25/2020																::
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
									::	09/23/2020		0.0.1		Initial Build																								::
									::	09/25/2020		1.0.0		Initial Release Version																						::
									::																																			::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::														  Known Issues																		::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::	None																																	::
									::																																			::
									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::NAME
::    HELP.cmd
::    <-4 SPACES    Do not exceed 73 columns to prevent text wrapping.->|
::
::
::SYNOPSIS
::    Provides help functionality for command line scripts              |
::
::
::SYNTAX
::    CALL HELP                                                         |
::
::
::DESCRIPTION
::    Provides help functionality for command line scripts by displaying|
::    the text of all lines beginning with ::, starting at the line 
::    preceeding ::NAME, and ending at :ENDOFHELP.                      |
::
::
::PARAMETERS
::    None                                                              |
::
::
:ENDOFPARAMETERS
::INPUTS
::    None                                                              |
::
::
::OUTPUTS
::    None                                                              |
::
::
::EXIT CODES
::    0  --  'Success'                                                  |
::    1090 - '::NAME NOT FOUND'
::    1404 - ':ENDOFHELP NOT FOUND'
::
::
::NOTES
::
::
::        NOTES                                                         |
::
::
::    -------------------------- EXAMPLE 1 --------------------------
::    <-4 SPACES       Do not exceed 69 columns to keep alignment.->|
::    EXAMPLE
:ENDOFHELP

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
	SET "FILE="%~f0""
	SET /A SKIP = 0

	::Parses each line of the file until getting to the ::NAME line, incrementing SKIP by 1 each time
	::The usebackq option is used to prevent errors, in the case that %FILE% contains quotes due to spaces in the filename
	FOR /F "usebackq" %%A IN (%FILE%) DO (
		SET /A SKIP += 1
		IF "%%A" EQU "::NAME" (
			GOTO :BREAK1
		)
	)

	::Exits with exit code 1090 '::NAME NOT FOUND' if no ::NAME line is found
	EXIT /B 1090
	:BREAK1

	::Displays the contents of all lines between the lines ::NAME and :ENDOFHELP.
	::The usebackq option is used to prevent errors, in the case that %FILE% contains quotes due to spaces in the filename
	FOR /F "usebackq skip=%SKIP% delims=" %%A IN (%FILE%) DO (
		IF "%%A" EQU ":ENDOFHELP" (
			GOTO :BREAK2
		)
		
		SET "LINE=%%A"
		IF "!LINE:~0,2!" EQU "::" (
			ECHO:!LINE:~2!
		)
	)

	::Exits with exit code 1404 ':ENDOFHELP NOT FOUND' if no ::NAME line is found
	EXIT /B 1404

:BREAK2

EXIT /B 0