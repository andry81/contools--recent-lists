@echo off

if defined CONTOOLS_RECENT_LISTS_PROJECT_ROOT_INIT0_DIR if exist "%CONTOOLS_RECENT_LISTS_PROJECT_ROOT_INIT0_DIR%\*" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat"
