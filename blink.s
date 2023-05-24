/* This program blinks the led embedded in the blue pill board. The led is
 * attached to pin PC13. This pin works as a GPIO, then it must be configured,
 * at assembly level, through the following registers:
 * 1) RCC register,
 * 2) GPIOC_CRL register, 
 * 3) GPIOC_CRH register, and
 * 4) GPIOC_ODR register.
 * 
 * Author: A. Geovanni Medrano-Chávez.
 * The following code is based on the explanation given in this video:
 * https://www.youtube.com/watch?v=KLWzyhOR3-Y,
 */



.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "ivt.s"
.include "gpio_map.inc"
.include "rcc_map.inc"

.section .text
.align	1
.syntax unified
.thumb
.global __main
__main:
# Setup
        # enabling clock in port C
        ldr     r0, =RCC_BASE
        mov     r1, 0x10 @ loads 16 in r1 to enable clock in port C (IOPC bit)
        str     r1, [r0, RCC_APB2ENR_OFFSET] @ M[RCC_APB2ENR] gets 16

        # reset pin 0 to 7 in GPIOC_CRL
        ldr     r0, =GPIOC_BASE @ moves base address of port C
        ldr     r1, =0x44444444 @ this constant signals the reset state
        str     r1, [r0, GPIOx_CRL_OFFSET] @ M[GPIOC_CRL] gets 0x44444444

        # set pin 13 as digital output
        ldr     r1, =0x44344444 @ PC13: output push-pull, max speed 50 MHz
        str     r1, [r0, GPIOx_CRH_OFFSET] @ M[GPIOC_CRH] gets 0x44344444

        # set led status initial value
        add     r0, GPIOx_ODR_OFFSET @ moves address of GPIOC_ODR register to r0
        mov     r1, 0x0
loop:   
        cmp     r1, 0x0 @ if r1 equals zero then turn PC13 on
        bne     L1 @ else, turns PC13 off
        mov     r3, 0x0 @ turns PC13 on
        b       L2
L1:     mov     r3, 0x2000 @ turns PC13 off
L2:     str     r3, [r0] @ M[GPIOC_ODR] gets r1 value
        # dirty delay
        ldr     r2, =2666667 @ r2 gets 2666667
        b       L3
L4:     sub     r2, r2, #1
L3:     cmp     r2, #0
        bge     L4
        eor     r1, #1 @ negates LSB of r1
        b       loop
