@echo off

if exist "C:\Program Files\Eagle Dynamics\DCS World OpenBeta\Scripts\ScriptingSystem.lua" (
    set DCSPath=C:\Program Files\Eagle Dynamics\DCS World OpenBeta
) else if exist "C:\Program Files\Eagle Dynamics\DCS World\Scripts\ScriptingSystem.lua" (
    set DCSPath=C:\Program Files\Eagle Dynamics\DCS World
) else (
    echo "DCS not found! Let us know so we can beef up this test script."
    exit
)

for /F "delims=" %%i in (%0) do set MyPath=%%~dpi

cd "%DCSPath%"

set LUA_PATH=%DCSPath%?.lua;%MyPath%src\?.lua;%MyPath%lib\?.lua;%MyPath%?.lua;;
lua "%MyPath%test\evac.lua" %*
