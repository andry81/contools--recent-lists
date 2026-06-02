@echo off

setlocal

call "%%~dp0._install\__init__.bat" || exit /b

rem CAUTION:
rem   Immediate Administrator permissions is required to pass a root project
rem   parameters into promoted environment of an external project script.
rem   So you must elevate now to avoid the elevation later.

call "%%CONTOOLS_PROJECT_ROOT%%/._install/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/_install.bat" || exit /b

exit /b 0
