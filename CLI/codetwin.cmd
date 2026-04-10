@echo off
setlocal

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "APP=%ROOT%\codetwin-cli\packages\opencode"
set "REMOTE_SERVER_DIR=%ROOT%\codetwin-remote-server"

if exist "%USERPROFILE%\.bun\bin\bun.exe" (
  set "BUN=%USERPROFILE%\.bun\bin\bun.exe"
  goto :bun_found
)

where bun >nul 2>nul
if %errorlevel%==0 (
  for /f "delims=" %%B in ('where bun') do (
    if not defined BUN set "BUN=%%B"
  )
)

if defined BUN goto :bun_found

echo Error: Bun is not installed. 1>&2
exit /b 1

:bun_found

if not exist "%APP%\" (
  echo Error: workspace not found at: %APP% 1>&2
  exit /b 1
)

if not exist "%APP%\node_modules\" (
  echo Installing dependencies...
  "%BUN%" install --cwd "%APP%"
  if %errorlevel% neq 0 exit /b %errorlevel%
)

if "%~1"=="" (
  "%BUN%" run --cwd "%APP%" dev "%CD%"
  exit /b %errorlevel%
)

"%BUN%" run --cwd "%APP%" dev %*
exit /b %errorlevel%