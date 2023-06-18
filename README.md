
# Practica  'Lab5' Configuracion de puertos GPIO


# Funcionamiento de la implementacion

En esta practica se modifico el archivo blink.s para que ahora enciendan diez LED conectados a los puertos GPIO del µC (blue pill stm32f103c8t6). 

Los LED muestran el valor binario de una variable. Si se
oprime un push button A, entonces se incrementa el valor
de la variable en una unidad. Si se oprime un push button B,
entonces el valor de la variable se decrementa. Si se
oprimen los dos botones, entonces el valor de la variable se reinicia a 0.


# Documentación

-Funcionamiento del Proyecto: Encendido de 10 LED con un valor binario de 0 a 10 con 2 botones push button para incremento y decremento, al pulsar ambos botones el valor de la variable se reinicia a 0.

-Compilacion del software: En una distribucion de linux basada en ubuntu se procedio a instalar los siguientes paquetes con el comando "sudo apt install gcc-arm-none-eabi stlink-tools
libusb-1.0-0-dev" :


    gcc-arm-none-eabi. Este es el compilador cruzado que permite generar código máquina para microcontroladores.

    stlink-tools. Este paquete contiene las utilizadas que permiten grabar un microcontrolador STM32 mediante el dispositivo ST-Link V2.

    libusb-1.0-0-dev. Este paquete contiene los controladores que permiten detectar la conexión con el ST-Link V2.

Posteriormente se establecieron alias para no emplear comandos verbosos(utilizando visual studio) de la siguiente manera:

    cd $HOME. Esta instruccion cambia el directorio a HOME donde se localiza bash

    code .bashrc. Esta instruccion abre el bash para establecer los alias


Alias a establecer:

    alias arm-gcc=arm-none-eabi-gcc

    alias arm-as=arm-none-eabi-as

    alias arm-objdump=arm-none-eabi-objdump

    alias arm-objcopy=arm-none-eabi-objcopy



Una vez establecidos los alias se utilizo una plantilla makefile proporcionada por el profesor del curso. Con dicha plantilla podemos realizar la compilacion con un simple comando el cual es el siguiente:
    
    make


Posteriormente, para realizar la grabación en el µC, se ejecuta la instruccion:

    st-flash write ‘prog.bin’ 0x8000000. 

    La cual sirve para escribir el binario (prog.bin) al µC. Donde prog.bin es el nombre del archivo generado por la plantilla makefile

    Significado de banderas:
    -> "0x8000000" indica la dirección de inicio en la memoria del microcontrolador donde se desea escribir el archivo binario. La dirección de memoria 0x8000000 es donde se almacenan las instrucciones y datos iniciales del programa, que se ejecutaran en el µC después de un reinicio o encendido. Comunmente dicha direccion, se utiliza como la ubicación de inicio del programa principal o firmware.




# Acerca de la plantilla Makefile

En el archivo main.s, es donde existe la función main. La cual contiene un apartado setup donde se configuran los periféricos del µC. Además, de que contiene un bucle loop donde se define el modo de operación del sistema.
Adicionalmente con esta plantilla tambien podemos escribir en el µC con el siguiente comando:

    make write


Diagrama de configuracion del µC (blue pill stm32f103c8t6)
![Logo](https://i.ibb.co/HFBQ2h1/Diagrama-STM32.png[/img][/url])




        
