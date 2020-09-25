									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									::																																			::
									::														FileName	SWITCHPARSER.cmd																::
									::														Author		John Hofmann															::
									::														Version		1.0.0																	::
									::														Date		09/24/2020																::
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
									::	09/24/2020		1.0.0		Initial Release Version																						::
									::																																			::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::														  Known Issues																		::
									::══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════::
									::	None																																	::
									::																																			::
									::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::NAME
::    SWITCHPARSER.CMD
::
::
::SYNOPSIS
::    Enables rudimentary switch parsing for command scripts
::
::
::SYNTAX
::    CALL SWITCHPARSER.CMD %*
::
::
::DESCRIPTION
::    Compares each parameter listed in the PARAMETERS block to each 
::    argument in %*, creating named variables set to TRUE for each
::    matching argument.
::
::
::PARAMETERS
::    -PARAMETER1
::        This script does not require or act on any parameters itself.
::        The parameters displayed here are merely examples to 
::        demonstrate the required format.
::
::    -PARAMETER2
::        Description.
::
:ENDOFPARAMETERS
::INPUTS
::    Strings
::
::        Use %* to pass the command line arguments from your script to 
::        this script.
::
::
::OUTPUTS
::    Variables
::
::        This script creates a named variable for each command line 
::        argument that matches one of the parameters in the PARAMETER
::        block.
::
::
::EXIT CODES
::    0  --  'SUCCESS'
::    1557 - '::PARAMETERS NOT FOUND'
::    1863 - ':ENDOFPARAMETERS NOT FOUND'
::    2821 - 'MISSING SETLOCAL ENABLEDELAYEDEXPANSION'
::
::
::NOTES
::
::
::        This script currently only works with switch style parameters.
::        support for argument based parameters will come in a future 
::        update.
::
::
::    -------------------------- EXAMPLE 1 --------------------------
::    EXAMPLE.cmd
::        @ECHO OFF
::        SETLOCAL ENABLEDELAYEDEXPANSION
::        CALL "SWITCHPARSER.cmd" %*
::        IF "%PARAMETER1%" EQU "TRUE" ECHO:HELLO WORLD
::
::    >EXAMPLE.cmd -PARAMETER1
::    HELLO WORLD
::
::    -------------------------- EXAMPLE 2 --------------------------
::    Using the same EXAMPLE.cmd file from EXAMPLE 1
::
::    Parameters are  not case sensitive, and extra arguments that do
::    not match any parameters are simply ignored.
::
::    >EXAMPLE.cmd -parameter1 -abadPARAMETER
::    HELLO WORLD
:ENDOFHELP

@ECHO OFF

::Checking that delayed expansion is enabled
SET "EXPANSIONTEST=TRUE"
IF "!EXPANSIONTEST!" NEQ "TRUE" (
	ECHO:This script requires delayed expansion. Please add SETLOCAL ENABLEDELAYEDEXPANSION to your script before calling this script.
	::Exits with exit code 2821 'MISSING SETLOCAL ENABLEDELAYEDEXPANSION' if delayed expansion is not enabled
	EXIT /B 2821
)

SET "FILE="%~f0""
SET /A SKIP = 0

::Parses each line of the file until getting to the ::PARAMETERS line, incrementing SKIP by 1 each time
::The usebackq option is used to prevent errors, in the case that %FILE% contains quotes due to spaces in the filename
FOR /F "usebackq" %%A IN (%FILE%) DO (
	SET /A SKIP += 1
	IF "%%A" EQU "::PARAMETERS" (
		GOTO :BREAK1
	)
)

::Exits with exit code 1557 '::PARAMETERS NOT FOUND' if no line beginning with ::PARAMETERS is found
EXIT /B 1557
:BREAK1
SET /A N = 0
SET "PARAMETERS="

::Searches for all lines between ::PARAMETERS and :ENDOFPARAMETERS that begin with "::    -" and stores them 
::in %PARAM% variables in the form %PARAM1%, %PARAM2%, etc..., keeping track of the total number found
FOR /F "usebackq skip=%SKIP% delims=" %%A IN (%FILE%) DO (
	IF "%%A" EQU ":ENDOFPARAMETERS" (
		GOTO :BREAK2
	)
	
	SET "LINE=%%A"
	SET "LINE=!LINE:|=!"
	SET "LINE=!LINE:<=!"
	SET "LINE=!LINE:>=!"
	
	IF "!LINE:~0,7!" EQU "::    -" (
		SET /A "N += 1"
		SET "PARAM!N!=!LINE:~6!"
		CALL SET "PARAM!N!=%%PARAM!N!: =%%"
	)
)

::Exits with exit code 1863 ':ENDOFPARAMETERS NOT FOUND' if no ":ENDOFPARAMETERS" line is found
EXIT /B 1863
:BREAK2

::Compares each command line argument with each PARAMETER, and for any matching values, creates a variable 
::names the same as the matching PARAMETER, and sets it to TRUE. You can then use
::                    IF "PARAMETERNAME" EQU "TRUE" (STUFF TO DO HERE)
::to build logic based on the parameters
FOR /L %%A IN (1,1,!N!) DO (
	FOR %%B IN (%*) DO (
		IF /I "%%B" EQU "!PARAM%%A!" (
			SET "!PARAM%%A:~1!=TRUE"
		) 
	)
)

EXIT /B 0
