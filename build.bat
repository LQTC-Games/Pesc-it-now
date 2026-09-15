@echo off
echo Ensamblando...
rgbasm -i include/ -o build/main.o src/main.asm

echo Enlazando...
rgblink -o build/juego.gb -n build/juego.sym build/main.o

echo Arreglando cabecera...
rgbfix -v -p 0xFF build/juego.gb

echo Compilacion terminada.
pause