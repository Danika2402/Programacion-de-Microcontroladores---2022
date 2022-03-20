; Este archivo contiene los macros a utilizar en el programa, a diferencia de 
; de los otros archivos, este usa la extensión .inc en lugar de .s y en todos 
; los archivos en donde se vayan a usar los macros, debe de usarse la directiva
; #include "macros.inc"
    
#include <xc.inc>
    
; -------------- MACROS --------------- 
; Macro para reiniciar el valor del TMR0
; **Recibe el valor a configurar en TMR_VAR**
RESET_TMR0 MACRO TMR_VAR
    BANKSEL TMR0	    ; cambiamos de banco
    MOVLW   TMR_VAR
    MOVWF   TMR0	    ; configuramos tiempo de retardo
    BCF	    T0IF	    ; limpiamos bandera de interrupción
    ENDM
