@echo off
setlocal enabledelayedexpansion

:: Crear la carpeta build si no existe para evitar errores
if not exist build mkdir build

set "OBJ_FILES="

echo Ensamblando...
:: Busca recursivamente todos los archivos .asm en la carpeta src
for /r src %%i in (*.asm) do (
    echo Ensamblando: %%i
    rgbasm -i include/ -o build/%%~ni.o "%%i"
    
    :: Guarda la lista de archivos .o generados en una variable
    set "OBJ_FILES=!OBJ_FILES! build/%%~ni.o"
)

echo Enlazando...
:: Pasa la variable con todos los .o al linker
rgblink -o build/juego.gb -n build/juego.sym !OBJ_FILES!

echo Arreglando cabecera...
rgbfix -v -p 0xFF build/juego.gb

echo Compilacion terminada.
pause