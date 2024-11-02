@echo off

rem Description:
rem   Script cleanups (deletes) recent lists from known places everythere in
rem   the Windows registry.
rem

setlocal

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\System64\*" (
  call :CMD "%%SystemRoot%%\System64\cmd.exe" /C @%%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY!
  exit /b -254
) >&2

:X64
:X32

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

set /A NEST_LVL-=1

exit /b %LAST_ERROR%

:MAIN
set "RECENT_LISTS_PTTN_FILE=%~1"

if not exist "%RECENT_LISTS_PTTN_FILE%" (
  echo.%~nx0: error: recent lists pattern file is not found: "%RECENT_LISTS_PTTN_FILE%"
  exit /b 255
) >&2

set "CMD_INDENT_STR=  "

for /F "usebackq eol=# tokens=1,* delims=|" %%i in ("%RECENT_LISTS_PTTN_FILE%") do (
  set "RECENT_LIST_RECORD=%%i|%%j"

  if "%%i" == "reg" (
    set "RECENT_LIST_REG_KEY_RECORD=%%j"

    for /F "tokens=1,* delims=|"eol^= %%k in ("%%j") do (
      if "%%k" == "*" (
        set "RECENT_LIST_REG_KEY_PATH=%%l"
        call :CLEANUP_RECENT_LIST_REG_KEY_ALL
      ) else if "%%k" == "." (
        for /F "tokens=1,2,* delims=|"eol^= %%m in ("%%l") do (
          set "RECENT_LIST_REG_KEY_PATH=%%m"
          set "RECENT_LIST_REG_KEY_TYPE=%%n"
          set "RECENT_LIST_REG_KEY_NAME=%%o"
          call :CLEANUP_RECENT_LIST_REG_KEY_NAME
        )
      ) else if "%%k" == "n" (
        for /F "tokens=1,2,* delims=|"eol^= %%m in ("%%l") do (
          set "RECENT_LIST_REG_KEY_PATH_RE=%%m"
          set "RECENT_LIST_REG_KEY_TYPE=%%n"
          set "RECENT_LIST_REG_KEY_NAME_RE=%%o"
          call :CLEANUP_RECENT_LIST_REG_KEY_NAME_RE
        )
      ) else call :CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN
    )
  ) else if "%%i" == "file" (
    set "RECENT_LIST_FILE_RECORD=%%j"

    for /F "tokens=1,* delims=|"eol^= %%k in ("%%j") do (
      if "%%k" == "ini" (
        for /F "tokens=1,* delims=|"eol^= %%m in ("%%l") do (
          if "%%m" == "*" (
            for /F "tokens=1,* delims=|"eol^= %%o in ("%%n") do (
              set "RECENT_LIST_FILE_INI_EXPAND_PATH=%%o"
              set "RECENT_LIST_FILE_INI_CLEANUP_INI_FILE=%%p"
              call :CLEANUP_RECENT_LIST_FILE_INI_SECTIONS_ALL
            )
          ) else call :CLEANUP_RECENT_LIST_FILE_RECORD_UNKNOWN
        )
      ) else call :CLEANUP_RECENT_LIST_FILE_RECORD_UNKNOWN
    )
  ) else if "%%i" == "cmd" (
    set "RECENT_LIST_CMD_RECORD=%%j"

    for /F "tokens=1,* delims=|"eol^= %%k in ("%%j") do (
      if "%%k" == "rmdir" (
        for /F "tokens=1,* delims=|"eol^= %%m in ("%%l") do (
          set "RECENT_LIST_CMD_RMDIR_EXPAND_PATH=%%m"
          set "RECENT_LIST_CMD_RMDIR_ARGS=%%n"
          call :CLEANUP_RECENT_LIST_CMD_RMDIR
        )
      ) else call :CLEANUP_RECENT_LIST_CMD_RECORD_UNKNOWN
    )
  ) else call :CLEANUP_RECENT_LIST_UNKNOWN
  echo.---
)

exit /b 0

rem delete existed key path
:CLEANUP_RECENT_LIST_REG_KEY_ALL
if not defined RECENT_LIST_REG_KEY_PATH goto CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN

echo."%RECENT_LIST_REG_KEY_PATH%"
call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_PATH%%" && (
  call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" delete "%%RECENT_LIST_REG_KEY_PATH%%" /f && (
    call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" add "%%RECENT_LIST_REG_KEY_PATH%%"
  )
)
exit /b

rem delete existed key name
:CLEANUP_RECENT_LIST_REG_KEY_NAME
if not defined RECENT_LIST_REG_KEY_NAME goto CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN

echo."%RECENT_LIST_REG_KEY_PATH% | %RECENT_LIST_REG_KEY_TYPE% | %RECENT_LIST_REG_KEY_NAME%"
call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_PATH%%" /v "%%RECENT_LIST_REG_KEY_NAME%%" && (
  call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" add "%%RECENT_LIST_REG_KEY_PATH%%" /v "%%RECENT_LIST_REG_KEY_NAME%%" /t "%%RECENT_LIST_REG_KEY_TYPE%%" /f
)
exit /b

rem delete existed key name by regexp
:CLEANUP_RECENT_LIST_REG_KEY_NAME_RE
if not defined RECENT_LIST_REG_KEY_NAME_RE goto CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN

set "REG_CMD_QUERY_BARE_FLAGS="

rem exact match
set "REG_CMD_FIND_BARE_FLAG=/v"
set "RECENT_LIST_REG_KEY_PATH=%RECENT_LIST_REG_KEY_PATH_RE%"
set "RECENT_LIST_REG_KEY_NAME=%RECENT_LIST_REG_KEY_NAME_RE%"

rem pattern in the key path
if "%RECENT_LIST_REG_KEY_PATH_RE:~-2%" == "\*" (
  set REG_CMD_QUERY_BARE_FLAGS= /s
  set "RECENT_LIST_REG_KEY_PATH=%RECENT_LIST_REG_KEY_PATH_RE:~0,-2%"
)

rem pattern in the key name
if "%RECENT_LIST_REG_KEY_NAME_RE:~-1%" == "*" (
  rem pattern match
  set "REG_CMD_FIND_BARE_FLAG=/f"
  set "RECENT_LIST_REG_KEY_NAME=%RECENT_LIST_REG_KEY_NAME_RE:~0,-1%"
)

set "RECENT_LIST_REG_KEY_SUBPATH=%RECENT_LIST_REG_KEY_PATH%"

echo."%RECENT_LIST_REG_KEY_PATH% | %RECENT_LIST_REG_KEY_TYPE% | %RECENT_LIST_REG_KEY_NAME_RE%"
call :CMD_ECHO_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_PATH%%" %%REG_CMD_FIND_BARE_FLAG%% "%%RECENT_LIST_REG_KEY_NAME%%"%%REG_CMD_QUERY_BARE_FLAGS%%
for /f "usebackq tokens=* delims=" %%i in (`@"%SystemRoot%\System32\reg.exe" query "%RECENT_LIST_REG_KEY_PATH%" %REG_CMD_FIND_BARE_FLAG% "%RECENT_LIST_REG_KEY_NAME%"%REG_CMD_QUERY_BARE_FLAGS%`) do (
  if not "%%i" == "" (
    set "REGQUERY_LINE=%%i"
    call :CLEANUP_RECENT_LIST_REG_KEY_NAME_RE_IMPL
  )
)
exit /b

:CLEANUP_RECENT_LIST_REG_KEY_NAME_RE_IMPL
if "%REGQUERY_LINE:~0,5%" == "HKEY_" set "RECENT_LIST_REG_KEY_SUBPATH=%REGQUERY_LINE%"

if not "%REGQUERY_LINE:~0,4%" == "    " exit /b 0

rem CAUTION: name must be without whitespaces!
set "REGQUERY_KEY_NAME="
for /f "tokens=1,* delims= "eol^= %%i in ("%REGQUERY_LINE:~4%") do set "REGQUERY_KEY_NAME=%%i"

call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_SUBPATH%%" /v "%%REGQUERY_KEY_NAME%%" && (
  call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" add "%%RECENT_LIST_REG_KEY_SUBPATH%%" /v "%%REGQUERY_KEY_NAME%%" /t "%%RECENT_LIST_REG_KEY_TYPE%%" /f
)

exit /b

rem delete existed ini file sections
:CLEANUP_RECENT_LIST_FILE_INI_SECTIONS_ALL
if not defined RECENT_LIST_FILE_INI_EXPAND_PATH goto CLEANUP_RECENT_LIST_FILE_RECORD_UNKNOWN
if not defined RECENT_LIST_FILE_INI_CLEANUP_INI_FILE goto CLEANUP_RECENT_LIST_FILE_RECORD_UNKNOWN

set "RECENT_LIST_FILE_INI_CLEANUP_INI_FILE_PATH=%CONTOOLS_RECENT_LISTS_PROJECT_OUTPUT_CONFIG_ROOT%\lists\%RECENT_LIST_FILE_INI_CLEANUP_INI_FILE%"

if not exist "%RECENT_LIST_FILE_INI_CLEANUP_INI_FILE_PATH%" goto CLEANUP_RECENT_LIST_FILE_RECORD_UNKNOWN

rem expand path
call set "RECENT_LIST_FILE_INI_PATH=%RECENT_LIST_FILE_INI_EXPAND_PATH%"

echo."%RECENT_LIST_FILE_INI_PATH%" ^| "%RECENT_LIST_FILE_INI_CLEANUP_INI_FILE%"
if not exist "%RECENT_LIST_FILE_INI_PATH%" exit /b 0

"%SystemRoot%\System32\cscript.exe" /NOLOGO "%TACKLELIB_PROJECT_ROOT%/vbs/tacklelib/tools/totalcmd/uninstall_totalcmd_wincmd.vbs" "%RECENT_LIST_FILE_INI_PATH%" "%RECENT_LIST_FILE_INI_PATH%" "%RECENT_LIST_FILE_INI_CLEANUP_INI_FILE_PATH%" || (
  echo.%~nx0: error: update of Total Commander main configuration file is aborted.
  exit /b 255
) >&2

exit /b 0

rem remove a directory
:CLEANUP_RECENT_LIST_CMD_RMDIR
if not defined RECENT_LIST_CMD_RMDIR_EXPAND_PATH goto CLEANUP_RECENT_LIST_CMD_RECORD_UNKNOWN

rem expand path
call set "RECENT_LIST_CMD_RMDIR_EXPAND_PATH=%RECENT_LIST_CMD_RMDIR_EXPAND_PATH%"

if not defined RECENT_LIST_CMD_RMDIR_ARGS goto RECENT_LIST_CMD_RMDIR_ARGS_NOT_DEFINED
if not "%RECENT_LIST_CMD_RMDIR_ARGS:~0,1%" == " " set "RECENT_LIST_CMD_RMDIR_ARGS= %RECENT_LIST_CMD_RMDIR_ARGS%"

:RECENT_LIST_CMD_RMDIR_ARGS_NOT_DEFINED

echo.^>rmdir%RECENT_LIST_CMD_RMDIR_ARGS% "%RECENT_LIST_CMD_RMDIR_EXPAND_PATH%"
rmdir%RECENT_LIST_CMD_RMDIR_ARGS% "%RECENT_LIST_CMD_RMDIR_EXPAND_PATH%"

exit /b 0

:CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN
echo.%~nx0: error: invalid registry record: "%RECENT_LIST_REG_KEY_RECORD%"
exit /b 0

:CLEANUP_RECENT_LIST_FILE_RECORD_UNKNOWN
echo.%~nx0: error: invalid file record: "%RECENT_LIST_FILE_RECORD%"
exit /b 0

:CLEANUP_RECENT_LIST_CMD_RECORD_UNKNOWN
echo.%~nx0: error: invalid command record: "%RECENT_LIST_CMD_RECORD%"
exit /b 0

:CLEANUP_RECENT_LIST_UNKNOWN
echo.%~nx0: error: invalid record: "%RECENT_LIST_RECORD%"
exit /b 0

:CMD
echo.^>%*
echo.
(
  %*
)
exit /b

:CMD_W_INDENT
call :CMD_ECHO_W_INDENT %%*
echo.
(
  %*
)
exit /b

:CMD_ECHO
echo.^>%*
exit /b

:CMD_ECHO_W_INDENT
echo.%CMD_INDENT_STR%^>%*
exit /b
