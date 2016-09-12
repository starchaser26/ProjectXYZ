@echo off

set pXYZ_ROOT=%CD%

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Please run as administrator
    exit /B 1
)

SET URHO3D_HOME=%pXYZ_ROOT%\libsrc\URHO3D-1.6
SET PATH=%PATH%;%pXYZ_ROOT%\lib\mingw-w64\i686-6.2.0-posix-dwarf-rt_v5-rev0\mingw32\bin

if not exist "%pXYZ_ROOT%\libsrc\URHO3D-1.6" (
    powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%pXYZ_ROOT%\libsrc\URHO3D-1.6.zip', '%pXYZ_ROOT%\libsrc'); }"
)

if exist "%pXYZ_ROOT%\build\vs_lib" (
    echo vs_lib build folder already exists. If the previous build failed then please remove the folder to try again.
    GOTO VSBUILD
)
echo Starting native build...
CALL libsrc\URHO3D-1.6\cmake_vs2015 build\vs_lib

:VSBUILD
if exist "%pXYZ_ROOT%\build\vs_lib\lib" (
    echo VS Library Folder already exists. If the previous build failed then please remove the folder to try again.
    GOTO EMSCRIPTEN
)
echo Starting native library build...
CALL "%VS140COMNTOOLS%vsdevcmd"
msbuild "%pXYZ_ROOT%\build\vs_lib\urho3d.sln"

:EMSCRIPTEN
if exist "%pXYZ_ROOT%\build\web_lib" (
    echo web_lib build folder already exists. If the previous build failed then please remove the folder to try again.
    GOTO MINGW32
)
echo Starting web build...
CALL libsrc\URHO3D-1.6\cmake_emscripten build\web_lib

:MINGW32
if exist "%pXYZ_ROOT%\build\web_lib\lib" (
    echo Web library build folder already exists. If the previous build failed then please remove the folder to try again.
    GOTO FINISH
)
echo Starting web library build...
cd build\web_lib
mingw32-make
cd "%pXYZ_ROOT%"

:FINISH
echo Finished!