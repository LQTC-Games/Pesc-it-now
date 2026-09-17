# Pesc-it-now


# Vamos a instalarlo

## Estructura del Entorno

Para que la configuración funcione correctamente, vamos a  organizar una carpeta principal (por ejemplo, `ensamblador`) que contenga:

* `bgb/` - Carpeta con el emulador BGB.
* `rgbds/` - Carpeta con los ejecutables de RGBDS (`rgbasm.exe`, `rgblink.exe`, etc.).
* `[nombre_del_repo]/` - La carpeta de este repositorio.

![Estructura de la carpeta ensamblador](sources/readmeIMG/ensambladorCarpeta.png)

## 1. Configuración de Variables de Entorno (Windows)

Para poder compilar el juego, tu sistema debe reconocer los comandos de RGBDS desde cualquier terminal.

1. Abre una terminal (CMD o PowerShell).
2. Pon el siguiente comando, sustituyendo `<rgbds_path>` por la ruta completa hacia tu carpeta de RGBDS (donde se encuentran `rgbasm.exe` y el resto de herramientas):

   ```cmd
   setx PATH "%PATH%<rgbds_path>;"
   ```
   *(Ejemplo: `setx PATH "%PATH%;C:\Users\tu_usuario\Desktop\ensamblador\rgbds"`)*

![Estructura de la carpeta ensamblador](sources/readmeIMG/ruta.png)

3. **Cierra la terminal** por completo para que los cambios tengan efecto.
4. Abre una terminal nueva y verifica la instalación escribiendo:

   ```cmd
   rgbasm -V
   ```
   Si la consola devuelve el número de versión, la configuración ta joya.

## 2. Configuración del Editor de Código

El proyecto está preparado para **Visual Studio Code**.

1. Abre la carpeta de este repositorio en VS Code.
2. Ve a las extensiones e instala **[RGBDS Z80](https://marketplace.visualstudio.com/items?itemName=donaldhays.rgbds-z80)**.

## 3. Compilación y Ejecución

Una vez que el entorno de desarrollo y el editor estén listos:

1. Abre una terminal dentro de la raíz de este repositorio (puedes usar la terminal de VS Code).
2. Crear antes la carpeta build en la raiz del repo
3. Ejecuta el script de compilación:

   ```cmd
   ./build.bat
   ```
4. Si la compilación es correcta, se generará el archivo ejecutable `.gb` dentro de la carpeta `build/`.
5. Abre ese archivo `.gb` utilizando el emulador **BGB** para probar el juego.




# Cheatsheet: Instrucciones más usadas en Ensamblador Game Boy (SM83)

| Instrucción | Categoría | Descripción | Ejemplo de Uso | Explicación del Ejemplo |
| :--- | :--- | :--- | :--- | :--- |
| **`LD`** | Memoria/Datos | Carga un valor de un origen a un destino. Es la instrucción más ejecutada. | `LD A, 255` | Guarda el valor 255 en el acumulador `A`. |
| **`LDH`** | Hardware | Carga rápida para la "Zero Page" (`$FF00-$FFFF`). Vital para gráficos y botones. | `LDH ($42), A` | Escribe el valor de `A` en `$FF42` (Scroll Y de la pantalla). |
| **`LDI` / `LD (HL+)`** | Memoria | Carga un valor usando la dirección de `HL` y luego le suma 1 a `HL`. | `LD (HL+), A` | Escribe `A` en la memoria y avanza al siguiente byte. Ideal para bucles. |
| **`INC` / `DEC`** | Aritmética | Suma 1 (`INC`) o resta 1 (`DEC`) a un registro. Más rápido que `ADD`/`SUB`. | `INC B` | Aumenta en 1 el contador del registro `B`. |
| **`ADD`** | Aritmética | Suma un valor al acumulador `A` (o suma valores de 16 bits en `HL`). | `ADD A, C` | Suma el valor de `C` al de `A` y guarda el resultado en `A`. |
| **`CP`** | Control | Compara un valor con `A` restándolos internamente. No altera `A`, solo actualiza las banderas. | `CP 10` | Compara `A` con 10. Si `A` es 10, activa la bandera Zero (`Z`). |
| **`XOR`** | Lógica | Operación "O Exclusivo". El uso principal en Game Boy es reiniciar variables. | `XOR A` | Forma más rápida y que menos memoria ocupa para poner `A` en 0. |
| **`AND`** | Lógica | Operación "Y Lógico". Se usa como máscara para "apagar" o aislar bits. | `AND %00001111` | Deja intactos los 4 bits de la derecha de `A` y pone a 0 los de la izquierda. |
| **`JR`** | Salto | "Jump Relative". Salta a otra línea de código si se cumple una condición. | `JR NZ, Bucle` | Salta a la etiqueta `Bucle` si la operación anterior **No** dio **Zero** (`NZ`). |
| **`CALL`** | Subrutinas | Llama a una función. Guarda dónde estaba para poder volver luego. | `CALL ApagarPantalla`| Pausa el código actual, ejecuta la rutina `ApagarPantalla` y luego vuelve. |
| **`RET`** | Subrutinas | "Return". Se pone al final de una rutina para volver a donde se hizo el `CALL`. | `RET` | Termina la función actual y devuelve el control al flujo principal. |
| **`PUSH` / `POP`**| Pila (Stack) | `PUSH` guarda registros en la pila temporalmente; `POP` los recupera. | `PUSH BC` <br> `POP BC` | Protege el valor de `BC` antes de usarlo para otra cosa y lo restaura después. |
| **`HALT`** | Sistema | Duerme la CPU hasta la siguiente interrupción (ej. refresco de pantalla). | `HALT` | Ahorra batería y sincroniza el juego a 60 FPS (fotogramas por segundo). |



# Cheatsheet: Multiplicación, División y Rotaciones (Shifts)

> ⚠️ **Nota:** La CPU de Game Boy no tiene instrucciones de multiplicar o dividir. Para multiplicar/dividir por 2, 4, 8, etc., se mueven los bits (Shifts). Para multiplicar por otros números (ej. x5), se hacen bucles sumando (`ADD`).

| Instrucción | Concepto Matemático | Descripción | Ejemplo de Uso | Explicación del Ejemplo |
| :--- | :--- | :--- | :--- | :--- |
| **`SLA`** | **Multiplicar por 2** | *Shift Left Arithmetic*. Desplaza todos los bits un espacio a la izquierda. Pone un `0` en el hueco que queda a la derecha. | `SLA B` | Si `B` es 3 (`00000011`), pasa a ser 6 (`00000110`). |
| **`SRL`** | **Dividir entre 2**<br>(Sin signo) | *Shift Right Logical*. Desplaza todos los bits a la derecha. Pone un `0` en el hueco de la izquierda. | `SRL A` | Si `A` es 10 (`00001010`), pasa a ser 5 (`00000101`). |
| **`SRA`** | **Dividir entre 2**<br>(Con signo) | *Shift Right Arithmetic*. Igual que `SRL`, pero **mantiene el bit de la izquierda intacto** (bit de signo para números negativos). | `SRA C` | Divide `C` entre 2, pero si era un número negativo, sigue siendo negativo. |
| **`RLA` / `RLCA`**| Rotación Izquierda | *Rotate Left (Accumulator)*. Rota los bits hacia la izquierda. El bit que sale por la izquierda entra por la derecha. | `RLA` | Muy rápido. Se usa para analizar bits individuales o en rutinas matemáticas complejas. |
| **`RRA` / `RRCA`**| Rotación Derecha | *Rotate Right (Accumulator)*. Rota los bits hacia la derecha. El bit que sale entra por la izquierda. | `RRA` | Gira los bits del Acumulador de forma circular. |
| **`SWAP`** | Multiplicar/Dividir por 16 | Intercambia la mitad izquierda del byte (4 bits) con la mitad derecha. **Exclusivo de Game Boy.** | `SWAP A` | Si `A` es `$1A` (26), pasa a ser `$A1` (161). Muy útil para gráficos y paletas de color. |
