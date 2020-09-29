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

::NAME
::    SCRIPTNAME
::    <-4 SPACES    Do not exceed 73 columns to prevent text wrapping.->|
::
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
::    -PARAMETER1
::        Description.
::        <-8 SPACES Don't exceed 73 columns to prevent text wrapping.->|
::
::    -PARAMETER2
::        Description.                                                  |
::
::    -h
::        Displays this help text.                                      |
::
::    -help
::        Displays this help text.                                      |
::
::
:ENDOFPARAMETERS
::INPUTS
::    Type of input                                                     |
::        Description of input.                                         |
::
::
::OUTPUTS
::    Type of output                                                    |
::        Description of output.                                        |
::
::
::EXIT CODES
::    0  --  'Success'                							        |
::    1234 - 'Description of exit code'  		                        |
::
::
::NOTES
::
::    NOTES                                                             |
::
::
::    -------------------------- EXAMPLE 1 --------------------------
::    <-4 SPACES       Do not exceed 69 columns to keep alignment.->|
::    EXAMPLE
::
::
:ENDOFHELP

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

CALL :SWITCHPARSER %*

IF "%H%" EQU "TRUE" (
	CALL :HELP
	EXIT /B %ERRORLEVEL%
)

IF "%HELP%" EQU "TRUE" (
	CALL :HELP
	EXIT /B %ERRORLEVEL%
)

::REPLACE THIS LINE WITH YOUR SCRIPT NewWindowsCommandScript.cmd Version 0.3.0
EXIT /B 0

:**FUNCTIONS**
::<PLACE FUNCTIONS HERE>

:HELP
	SETLOCAL ENABLEDELAYEDEXPANSION
	SET "FILE="%~f0""
	SET /A SKIP = 0

	::Parses each line of the file until getting to the ::NAME line, incrementing SKIP by 1 each time
	::The usebackq option is used to prevent errors, in the case that %FILE% contains quotes due to spaces in the filename
	FOR /F "usebackq" %%A IN (%FILE%) DO (
		SET /A SKIP += 1
		IF "%%A" EQU "::NAME" (
			GOTO :HELPBREAK1
		)
	)

	::Exits with exit code 1090 '::NAME NOT FOUND' if no ::NAME line is found
	EXIT /B 1090
	:HELPBREAK1

	::Displays the contents of all lines between the lines ::NAME and :ENDOFHELP.
	::The usebackq option is used to prevent errors, in the case that %FILE% contains quotes due to spaces in the filename
	FOR /F "usebackq skip=%SKIP% delims=" %%A IN (%FILE%) DO (
		IF "%%A" EQU ":ENDOFHELP" (
			GOTO :HELPBREAK2
		)
		
		SET "LINE=%%A"
		IF "!LINE:~0,2!" EQU "::" (
			ECHO:!LINE:~2!
		)
	)

	::Exits with exit code 1404 ':ENDOFHELP NOT FOUND' if no ::NAME line is found
	EXIT /B 1404

	:HELPBREAK2

EXIT /B 0

:SWITCHPARSER *%
	::Checking that delayed expansion is enabled
	SET "EXPANSIONTEST=TRUE"
	IF "!EXPANSIONTEST!" NEQ "TRUE" (
		ECHO:This function requires delayed expansion. Please add SETLOCAL ENABLEDELAYEDEXPANSION to your script before calling this function.
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
			GOTO :SWITCHPARSERBREAK1
		)
	)

	::Exits with exit code 1557 '::PARAMETERS NOT FOUND' if no line beginning with ::PARAMETERS is found
	EXIT /B 1557
	:SWITCHPARSERBREAK1
	SET /A N = 0
	SET "PARAMETERS="

	::Searches for all lines between ::PARAMETERS and :ENDOFPARAMETERS that begin with "::    -" and stores them 
	::in %PARAM% variables in the form %PARAM1%, %PARAM2%, etc..., keeping track of the total number found
	FOR /F "usebackq skip=%SKIP% delims=" %%A IN (%FILE%) DO (
		IF "%%A" EQU ":ENDOFPARAMETERS" (
			GOTO :SWITCHPARSERBREAK2
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
	:SWITCHPARSERBREAK2

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
