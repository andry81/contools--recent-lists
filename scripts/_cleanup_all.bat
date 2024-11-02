@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%~dp0cleanup_windows_shell.bat"
call "%%~dp0cleanup_windows_internal_apps.bat"

call "%%~dp0cleanup_7zip.bat"
call "%%~dp0cleanup_adobe_acrobat_reader.bat"
call "%%~dp0cleanup_araxis_merge.bat"
call "%%~dp0cleanup_mpc_hc.bat"
call "%%~dp0cleanup_totalcmd.bat"

exit /b 0
