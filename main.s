.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "ivt.s"
.include "gpio_map.inc"
.include "rcc_map.inc"
.include "systick_map.inc"
.include "nvic_reg_map.inc"
.include "afio_map.inc"
.include "exti_map.inc"

.section .text
.align	1
.syntax unified
.thumb
.global __main


wait_ms:
        # Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        # Body function
        mov     r0, #255 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
# for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       L0
# for (j = 0; j < tick; j++)
L3:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       L1
L2:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
L1:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     L2
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
L0:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     L3
        # Epilogue
        adds    r7, r7, #28
        mov	    sp, r7
        pop	    {r7}
        bx	    lr




@ Esta funcion reinicia el contador a 0
reset:
        @ Prologo
        push    {r7, lr} @ respalda r7 y lr
        sub     sp, sp, #8 @ respalda un marco de 16 bytes
        add     r7, sp, #0 @ actualiza r7
        @ contador = 0
        ldr 	r3, =GPIOB_BASE
	mov 	r1, 0x0
	str 	r1, [r3, GPIOx_ODR_OFFSET]
	str	r1, [r7, #4]
	ldr	r3, [r7, #4]
	mov 	r0, r3

        @ Epilogo
        mov     r0, #0
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx	lr      



                                 @ PAGINA 378 PDF LIBRO ZHU 

# Esta funcion lee que se esta presionado (boton PA4 incremento. PA0 Decremento o ambos para reiniciar)
read_button_input:
        @ Prologo
	push	{r7} @ respalda r7
	sub 	sp, sp, #12 @ respalda un marco de 16 bytes
	add	r7, sp, #0 @ actualiza r7
        @ Lectura de boton(es)
	str 	r0, [r7] @ respalda el argumento recibido desde loop (que boton se presiona o ambos)
        ldr	r0, =GPIOA_BASE
	ldr 	r1, [r0, GPIOx_IDR_OFFSET]
	ldr 	r0, [r7] @ carga en r0 el valor del argumento recibido desde loop (que boton se presiona o ambos)
	and	r1, r1, r0 @ aplica una and entre el estado actual de GPIOA_IDR y el argumento recibido desde loop
	cmp	r1, r0 
	beq	L4 @ si son iguales sale de la funcion junto con el valor respectivo (leido)
        @ si no se presiona nada devuelve 0
	mov	r0, #0 @ return 0
L4:
        @ Epilogo
	adds 	r7, r7, #12
	mov	sp, r7
	pop 	{r7}
	bx	lr




# Esta funcion realiza el debouncing si se presiona un boton o ambos
is_button_pressed:
        @ Prologo
	push 	{r7, lr} @ respalda r7 y lr
	sub	sp, sp, #24 @ respalda un marco de 32 bytes
	add	r7, sp, #0 @ actualiza r7
        
	str 	r0, [r7, #4] @ respalda el argumento recibido desde loop
@ read_button_input
@ if (button is not pressed)
@     return false
	ldr	r0, [r7, #4] @ carga el argumento recibido desde loop
	bl	read_button_input
	ldr 	r3, [r7, #4] @ carga el valor recibido desde read_button_input
	cmp	r0, r3 
	beq	L5 @ si hay al menos un boton presionado realiza el debouncing 
        @ si no se presiona ningun boton (el valor recibido desde read_button_input es 0) sale de la funcion y devuelve 0 (false)
        @ Epilogo
	mov	r0, #0 @ return 0
	adds	r7, r7, #24
	mov	sp, r7 
	pop 	{r7, lr}
	bx	lr
L5:
@ counter = 0
	mov	r3, #0 @ counter = 0
	str	r3, [r7, #8] @ guarda el valor de counter dentro del marco
@ for (int i = 0, i < 10, i++) 
	mov     r3, #0 @ i = 0;
        str     r3, [r7, #12] @ guarda el valor de i dentro del marco
        b       L6
L9:     
@ wait 5 ms
	mov 	r0, #50 @ 5ms a delay (wait_ms)
	bl   	wait_ms
@ read button input
@ if (button is not pressed)
@    counter = 0
	ldr	r0, [r7, #4] @ carga el argumento recibido desde loop
	bl	read_button_input
	ldr 	r3, [r7, #4] @ carga el valor recibido desde read_button_input
	cmp	r0, r3 
	beq 	L7 @ si hay al menos un boton presionado se aumenta el contador una unidad
	mov 	r3, #0 @ counter = 0
	str	r3, [r7, #8] @ guarda el valor de counter dentro del marco
L7:		
@ else
@ counter = counter + 1
	ldr 	r3, [r7, #8] @ carga en r3 el valor de counter
	add	r3, #1 @ suma una unidad a counter
	str 	r3, [r7, #8] @ guarda el valor de counter dentro del marco
@ if (counter >= 4)
@    return true
	ldr 	r3, [r7, #8] @ carga en r3 el valor de counter
	cmp	r3, #4 @ counter >= 4 ?
	blt	L8 @ si counter < 4 sigue dentro del ciclo
	ldr	r0, [r7, #4] @ carga el valor de counter en r0 
        @ Epilogo
	adds	r7, r7, #24
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr
L8:
	ldr     r3, [r7, #12] @ carga en r3 el valor de i
        add     r3, #1 @ i++
        str     r3, [r7, #12] @ guarda el valor de i dentro del marco
L6:     
	ldr     r3, [r7, #12] @ carga en r3 el valor de i
        cmp     r3, #10 @ i < 10 ?
        blt     L9 @ si i < 10 sigue dentro del ciclo
@ return false
	@ Epilogo
	mov 	r0, #0 @ return 0
	adds	r7, r7, #24
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr








__main:
@setup:
        @Prologo
        push 	{r7, lr} @ respalda r7 y lr
	sub 	sp, sp, #8 @ respalda un marco de 16 bytes
	add	r7, sp, #0 @ actualiza r7


@ Configuracion de puertos de reloj
        @ Habilitacion de puertos A y B
        ldr     r1, =RCC_BASE 
        mov     r2, 0xC @ carga 12 (1100) en r2 para habilitar reloj en puertos A (IOPA) y puertos B (IOPB)
        str     r2, [r1, RCC_APB2ENR_OFFSET]


@ configuracion de pines de entrada y salida
        @ Configura los puertos PA4 y PA0 como entradas (2 push button) 
        ldr     r1, =GPIOA_BASE 
        ldr     r2, =0x44484448 @ constante que establece el estado de pines 
        str     r2, [r1, GPIOx_CRL_OFFSET]

        @ Configura los puertos PA15 - PA8 en modo reset
        ldr     r1, =GPIOA_BASE
        ldr     r2, =0x44444444 @ constante que establece el estado de pines 
        str     r2, [r1, GPIOx_CRH_OFFSET]

        @ Configura los puertos PB7 - PB5 como salidas push pull (3 LEDS) y PB4 - PB0 en modo reset
        ldr     r1, =GPIOB_BASE
        ldr     r2, =0x33344444 @ constante que establece el estado de pines 
        str     r2, [r1, GPIOx_CRL_OFFSET] 

        @ Configura los puertos PB15 en reset y PB14 - PB8 como salidas push pull (7 LEDS)
        ldr     r1, =GPIOB_BASE
        ldr     r2, =0x43333333 @ constante que establece el estado de pines 
        str     r2, [r1, GPIOx_CRH_OFFSET]

        

@ Inicializacion de leds 
        ldr     r3, =GPIOB_BASE  
        mov     r4, 0x0 @ inicializa los leds como apagados
        str     r4, [r3, GPIOx_ODR_OFFSET] @ guarda en r4 el estado de los leds (0)
        mov     r3, 0x0 @ contador de leds inicializado en 0
        str     r3, [r7, #4] @ guarda el valor del contador para los leds dentro del marco

         
loop:   
@ Verificar si ambos push button estan presionados
        mov     r0, 0x11 @ carga un valor de 17 (0001 0001) para indicar que se quiere leer los bits 5 y 0 (PA4, PA0; 2 push button)
        bl      is_button_pressed 
        cmp     r0, 0x11
        bne     L10 @ Si ambos no estan presionados, ver si alguno esta presionado
        bl      reset
        str     r0, [r7, #4] @ guarda el estado de los leds dentro del marco
L10:
@ Verificar si algun boton se presiona 
@ Si se presiona el boton del pin PA4 (incremento)
        mov     r0, 0x10 @ carga un valor de 16 (0001 0000) para indicar que se quiere leer el bit 5 (PA4 push button para incremento)
        bl      is_button_pressed 
        cmp     r0, 0x10
        bne     L11 @ si no se presiona, ver si el pin PB6 se presiona
        @ si se presiona, entonces incrementa 
        ldr     r1, =GPIOB_BASE @ carga la direccion de GPIOB_ODR a r1
        ldr     r2, [r7, #4] @ carga en r2 el valor actual del contador 
        adds    r2, r2, #1 @ aumenta en 1 el valor del contador
        str     r2, [r7,#4] @ almacena el nuevo valor del contador dentro del marco
        mov     r3, r2 @ carga en r3 el valor del contador
        lsl     r3, r3, #5 @ desplaza 5 unidades a la izquierda por el desfase donde se ubican los leds (el primer led se ubica en la 5ta posicion PA4)
        str     r3, [r1, GPIOx_ODR_OFFSET] @ almacena el nuevo valor de los LEDS (GPIOA_ODR) +1        

L11:    
@ Si se presiona el boton del pin PA0 (decremento)
        mov     r0, 0x01 @ carga un valor de 1 (0001) para indicar que se quiere leer el bit 0 (PA0 push button para decremento)
        bl      is_button_pressed
        cmp     r0, 0x01
        bne     L12 @ Si no se presiona, vuelve a loop
        @ si se presiona, entonces decrementa 
        ldr     r1, =GPIOB_BASE @ carga la direccion de GPIOA_IDR a r1
        ldr     r2, [r7, #4] @ carga en r2 el valor actual del contador
        sub     r2, r2, #1 @ decrementa en 1 el valor del contador
        str     r2, [r7, #4] @ almacena el nuevo valor del contador dentro del marco
        mov     r3, r2 @ carga en r3 el valor del contador
        lsl     r3, r3, #5 @ desplaza 5 unidades a la izquierda por el desfase donde se ubican los leds (el primer led se ubica en la 5ta posicion PA4)
        str     r3, [r1, GPIOx_ODR_OFFSET] @ almacena el nuevo valor de los LEDS (GPIOA_ODR) -1       

L12:
        b       loop
