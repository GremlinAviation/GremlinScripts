@echo off

cd docs\api\ & ^
ldoc.lua.bat -c gremlin.ldoc . & ^
ldoc.lua.bat -c evac.ldoc . & ^
ldoc.lua.bat -c urgency.ldoc . & ^
ldoc.lua.bat -c waves.ldoc . & ^
cd ..\..\ & ^
mdbook build
