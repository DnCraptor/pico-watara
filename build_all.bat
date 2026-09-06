@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem Locate CMake. Prefer PATH, then the Pico VS Code SDK cache.
set "CMAKE="
for /f "delims=" %%I in ('where cmake.exe 2^>nul') do if not defined CMAKE set "CMAKE=%%I"
if not defined CMAKE if exist "%USERPROFILE%\.pico-sdk" (
    for /f "delims=" %%I in ('where /r "%USERPROFILE%\.pico-sdk" cmake.exe 2^>nul') do if not defined CMAKE set "CMAKE=%%I"
)
if not defined CMAKE (
    echo ERROR: cmake.exe not found. 1>&2
    exit /b 1
)

rem Locate Ninja. Pico VS Code does not necessarily put it in PATH.
set "NINJA="
for /f "delims=" %%I in ('where ninja.exe 2^>nul') do if not defined NINJA set "NINJA=%%I"
if not defined NINJA if exist "%USERPROFILE%\.pico-sdk" (
    for /f "delims=" %%I in ('where /r "%USERPROFILE%\.pico-sdk" ninja.exe 2^>nul') do if not defined NINJA set "NINJA=%%I"
)
if not defined NINJA (
    echo ERROR: ninja.exe not found in PATH or "%USERPROFILE%\.pico-sdk". 1>&2
    exit /b 1
)

echo CMake: %CMAKE%
echo Ninja: %NINJA%

set "BUILD_ROOT=build\release-matrix"

call :build_platform rp2040 || goto :failed
call :build_platform rp2350 || goto :failed

echo.
echo All 48 RP2040/RP2350 release configurations built successfully.
exit /b 0

:build_platform
set "PLATFORM=%~1"
call :build_board %PLATFORM% murmulator || exit /b 1
call :build_board %PLATFORM% murmulator2 || exit /b 1
call :build_board %PLATFORM% olimex-pico-pc || exit /b 1
if /I "%PLATFORM%"=="rp2040" (
    call :build_board %PLATFORM% waveshare_rp2040_pizero || exit /b 1
) else (
    call :build_board %PLATFORM% waveshare_rp2350_pizero || exit /b 1
)
exit /b 0

:build_board
call :build_one %1 %2 VGA PWM || exit /b 1
call :build_one %1 %2 VGA I2S || exit /b 1
call :build_one %1 %2 HDMI PWM || exit /b 1
call :build_one %1 %2 HDMI I2S || exit /b 1
call :build_one %1 %2 SOFTTV PWM || exit /b 1
call :build_one %1 %2 SOFTTV I2S || exit /b 1
exit /b 0

:build_one
set "PLATFORM=%~1"
set "BOARD=%~2"
set "VIDEO=%~3"
set "AUDIO=%~4"
set "BDIR=%BUILD_ROOT%\%PLATFORM%\%BOARD%\%VIDEO%\%AUDIO%"

set "VGA_OPT=OFF"
set "HDMI_OPT=OFF"
set "SOFTTV_OPT=OFF"
if /I "%VIDEO%"=="VGA" set "VGA_OPT=ON"
if /I "%VIDEO%"=="HDMI" set "HDMI_OPT=ON"
if /I "%VIDEO%"=="SOFTTV" set "SOFTTV_OPT=ON"

set "I2S_OPT=OFF"
if /I "%AUDIO%"=="I2S" set "I2S_OPT=ON"

echo.
echo ============================================================
echo %PLATFORM% / %BOARD% / %VIDEO% / %AUDIO%
echo ============================================================

if exist "%BDIR%" rmdir /s /q "%BDIR%"

"%CMAKE%" -G Ninja -S . -B "%BDIR%" ^
  -DCMAKE_MAKE_PROGRAM:FILEPATH="%NINJA%" ^
  -DCMAKE_BUILD_TYPE=MinSizeRel ^
  -DRELEASE_BUILD=ON ^
  -DPICO_PLATFORM=%PLATFORM% ^
  -DPICO_BOARD=%BOARD% ^
  -DVGA=%VGA_OPT% ^
  -DHDMI=%HDMI_OPT% ^
  -DSOFTTV=%SOFTTV_OPT% ^
  -DTV=OFF ^
  -DTFT=OFF ^
  -DILI9341=OFF ^
  -DI2S=%I2S_OPT% ^
  -DI2S_CS4334=OFF
if errorlevel 1 exit /b 1

"%CMAKE%" --build "%BDIR%"
if errorlevel 1 exit /b 1
exit /b 0

:failed
echo.
echo Release matrix build FAILED.
exit /b 1
