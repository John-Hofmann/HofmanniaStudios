									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									::																																			::
									::														FileName	HELP.cmd																::
									::														Author		John Hofmann															::
									::														Version		0.0.1																	::
									::														Date		09/23/2020																::
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
::    0 = Success                                                       |
::    5926 - ::NAME NOT FOUND
::    5945 - :ENDOFHELP NOT FOUND
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
	SET "SKIP="
	::Finds the line number of the line beginning with ::NAME, and, if SKIP is not already defined, sets SKIP to that number minus 2.
	::This prevents a second ::NAME line further down the file from causing incorrect output.
	::The delims=: is required to ensure that only the line number is returned as %A, and not the line text.
	FOR /F "delims=:" %%A IN ('FINDSTR /B /N "::NAME" %FILE%') DO IF NOT DEFINED SKIP SET /A "SKIP=%%A-2"
	::Exits with exit code 5926 if no line beginning with ::NAME is found.
	IF NOT DEFINED SKIP EXIT /B 5926
	::Displays the contents of all lines starting with :: between the lines ::NAME and :ENDOFHELP.
	::usebackq is necessary to provide support for filepaths with spaces, as without it anything enclosed in " is considered a string instead of a file.
	FOR /F "usebackq skip=%SKIP% delims=" %%A IN (%FILE%) DO (
		SET "LINE=%%A"
		IF "!LINE:~0,2!" EQU "::" (ECHO:!LINE:~2!) ELSE (IF "!LINE!" EQU ":ENDOFHELP" (ECHO: & EXIT /B 0))
	)
EXIT /B 5945
