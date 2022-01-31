;Archivo:	main.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	contador en el puerto A
;Hardware:	Leds en puerto A
;    
;Creado:	24/01/2022
;Ultima modificacion: 24/01/2022
    
    
PROCESSOR 16F887
#include <xc.inc>
    
CONFIG FOSC  =   INTRC_NOCLKOUT
CONFIG WDTE  =   OFF
CONFIG PWRTE =   ON
CONFIG MCLRE =   OFF
CONFIG CP    =   OFF
CONFIG CPD   =   OFF
    
CONFIG BOREN =   OFF
CONFIG IESO  =   OFF
CONFIG FCMEN =   OFF
CONFIG LVP   =   ON
    
CONFIG WRT   =   OFF
CONFIG BOR4V =   BOR40V
    
;------------------------------------------------------------------------------
    
PSECT udata_bank0
    cont_small: DS 1 
    cont_big:   DS 1
    
PSECT resVect, class=CODE,abs, delta=2
;-----------------Vector Reset-----------------
ORG 00h
resetVec:
    PAGESEL main
    goto main
	
;---------------CONFIGURACION--------------------------------------------------

main:
    bsf	    STATUS, 5
    bsf	    STATUS, 6 ;banco 11
    clrf    ANSEL
    clrf    ANSELH
    
    bsf	    STATUS, 5
    bcf	    STATUS, 6
    clrf    TRISA
    
    bcf	    STATUS, 5
    bcf	    STATUS, 6
    clrf    PORTA   
    
;-------------LOOP-------------------------------------------------------------
    
loop:
    incf    PORTA, 1
    call    delay_big
    goto    loop
    
;-----------sub rutinas--------------------------------------------------------
    
delay_big:
    movlw   198 ;=100ms	    ;1us    (50)
    movwf   cont_big	    ;1us
    call    delay_small	    ;2us    (500 + 5)*x  + 4us = 100000 us
    decfsz  cont_big, 1	    ;1us			
    goto    $-2		    ;2us
    return		    ;2us
    
delay_small:
    movlw   165	;=500us	    ;1us	(150)
    movwf   cont_small	    ;1us
    decfsz  cont_small, 1   ;1us    (3us * x) + 4us = 500us
    goto    $-1		    ;2us
    return		    ;2us
    
END