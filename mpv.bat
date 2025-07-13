@echo off
setlocal

rem Prepend our dlls folder to PATH
set PATH=%~dp0dlls;%PATH%

rem Call the console build (or GUI build if you prefer)
"%~dp0mpv.com" %*

endlocal
