@echo off

rem objconv -fmasm file.obj here.asm

rem /Cp - preserve case of identifiers
rem /WX - treat warnings as errors
rem /Zd - add line number debug info
rem /Zi - add symbolic debug info

set ML64="ml64.exe" /nologo /WX /Cp /I.
set LIBEXE="lib.exe" /nologo

cd asm

echo Compiling...
%ML64% /Fo obj\maths.obj /c maths.asm
