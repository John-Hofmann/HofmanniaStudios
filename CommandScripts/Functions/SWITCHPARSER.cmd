									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									::																																			::
									::														FileName	SWITCHPARSER.cmd																::
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
::    SCRIPTNAME
::    <-4 SPACES    Do not exceed 73 columns to prevent text wrapping.->|
::
::SYNOPSIS
::    Synopsis                                                          |
::
::
::SYNTAX
::    Syntax                                                            |
::
::
::DESCRIPTION
::    Description                                                       |
::
::
::PARAMETERS
::    -PARAMETER1                                                       |
::        Description.
::        <-8 SPACES Don't exceed 73 columns to prevent text wrapping.->|
::
::    -PARAMETER2                                                       |
::        Description.                                                  |
::
:ENDOFPARAMETERS
::INPUTS
::    Type of input                                                     |
::
::
::        Description of input.                                         |
::
::
::OUTPUTS
::    Type of output                                                    |
::
::
::        Description of output.                                        |
::
::
::EXIT CODES
::    %ERRORLEVEL% = Description of exit code.                          |
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
SET "DEBUG=REM "
IF /I "%~1" EQU "-DEBUG" (
	SHIFT /1
	SET "DEBUG=ECHO:"
)
SETLOCAL ENABLEDELAYEDEXPANSION
	%DEBUG%Setting FILE...
	SET "FILE="%~f0""
	%DEBUG%Setting SKIP...
	SET "SKIP="
	FOR /F "delims=:" %%A IN ('FINDSTR /B /N "::PARAMETERS" %FILE%') DO (
		%DEBUG%Searching for ::PARAMETERS...
		SET /A "SKIP=%%A-2"
		GOTO :BREAK1
	)
	:BREAK1
	%DEBUG%:BREAK1
	IF NOT DEFINED SKIP (
		%DEBUG%SKIP not defined...
		EXIT /B 5926
	)
	%DEBUG%Setting PARAMETERCOUNT...
	SET "PARAMETERCOUNT=0"
	%DEBUG%Setting PARAMETERS...
	SET "PARAMETERS="
	FOR /F "usebackq skip=%SKIP% delims=" %%A IN (%FILE%) DO (
		%DEBUG%Searching for parameters...
		IF "%%A" EQU ":ENDOFPARAMETERS" (
			%DEBUG%ENDOFPARAMETERS...
			ECHO:!PARAMETERS!
			ECHO:!PARAMETERCOUNT!
			EXIT /B 0
		)
		SET "LINE=%%A"
		SET "LINE=!LINE:|=!"
		SET "LINE=!LINE:<=!"
		SET "LINE=!LINE:>=!"
		FOR /F "delims=: " %%B IN ('ECHO:!LINE! ^| FINDSTR /I /C:"::    -"') DO (
			SET "PARAMETERS=!PARAMETERS!%%B;"
			SET /A "PARAMETERCOUNT += 1"
		)
	)
EXIT /B 1

:**FUNCTIONS**
<PLACE FUNCTIONS HERE>
