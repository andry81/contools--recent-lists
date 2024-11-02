@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%~dp0.impl\cleanup_by_recent_list.bat" "%%CONTOOLS_RECENT_LISTS_PROJECT_OUTPUT_CONFIG_ROOT%%\lists\windows_shell.lst"
