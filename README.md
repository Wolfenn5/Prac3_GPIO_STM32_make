

# Configuración de GPIO
## Compilación del proyecto
Al utilizar un Make file podemos realizar el proceso de compilación con un simple comando

    make
Este comando se encarga de hacer la generación del archivo con extensión .bin, el nombre de este archivo lo definimos en la instrucción all del Makefile

### Grabación
Para realizar la grabación del binario en el microcontrolador debemos ejecutar el comando:

    st-flash write prog.bin 0x8000000

Donde 'prog.bin' es el nombre del binario generado

## Diagrama de Hardware

# Configuración de GPIO
## Compilación del proyecto
Al utilizar un Make file podemos realizar el proceso de compilación con un simple comando

    make
Este comando se encarga de hacer la generación del archivo con extensión .bin, el nombre de este archivo lo definimos en la instrucción all del Makefile

### Grabación
Para realizar la grabación del binario en el microcontrolador debemos ejecutar el comando:

    st-flash write prog.bin 0x8000000

Donde 'prog.bin' es el nombre del binario generado
