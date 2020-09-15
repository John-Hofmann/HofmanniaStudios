::FileName	PowerShellWrapper.exe
::Author	John Hofmann
::Version	0.0.1
::Date		09/14/2020
::
::Changelog
::	0.0.01	Initial Build
::
::Known Issues
::	None

@ECHO OFF
START "%~nx0" /D "%ALLUSERSPROFILE%" /WAIT /B PowerShell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command $codeStart = (Select-String -Pattern '^^:PowerShell Code Start' -Path '%~f0').LineNumber; $lineCount = (Get-Content '%~f0').Length - $codeStart; Get-Content '%~f0' -Last $lineCount ^| ForEach-Object {$commands += \"$_`n\"}; $scriptBlock = [scriptblock]::Create($commands); Invoke-Command $scriptBlock
EXIT /B %ERRORLEVEL%

:PowerShell Code Start
#Sample Code
'Success!' | Write-Host -ForegroundColor Green
Read-Host
Exit 7
