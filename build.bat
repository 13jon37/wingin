@echo off

if not exist build mkdir build
pushd src
odin build . -out:../build/main.exe -debug
popd