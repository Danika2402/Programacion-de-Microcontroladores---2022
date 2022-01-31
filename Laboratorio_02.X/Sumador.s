;Archivo:	Sumador.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:	30/01/2022
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
	
PSECT code, delta=2, abs
ORG 100
;---------------CONFIGURACION--------------------------------------------------

main:
    bsf	    STATUS,5	;banco 01
    bsf	    STATUS, 6	;banco 11
    clrf    ANSEL
    clrf    ANSELH
    
    bcf	    STATUS,6	;BANCO 01   
    bsf	    TRISA, 0
    bsf	    TRISA, 1
    clrf    TRISB
    
    bcf	    STATUS, 5
    clrf    PORTB

;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
	    //skip la siquiente linea
loop:
    btfss   PORTA, 0
    call    ANTIREBOTE1
    
    btfss   PORTA, 1
    call    ANTIREBOTE2
    
    goto loop
    
;-----------sub rutinas--------------------------------------------------------    
/*CHECKBOTON1:
    btfsc   PORTA, 0 
    goto    $-1
    return

CHECKBOTON2:
    btfsc   PORTA, 1
    goto    $-1
    return*/
ANTIREBOTE1:
    btfss   PORTA,0 //btfsc revisa si el bit esta apagado, 
    goto    $-1		    //skip la siguiente linea
    incf    PORTB, F
    movlw   0b00001111
    andwf   PORTB
    //goto    CHECKBOTON1
    return
    
ANTIREBOTE2:
    btfss   PORTA,1
    goto    $-1
    decfsz  PORTB, F
    movlw   0b00001111
    andwf   PORTB
    //goto    CHECKBOTON2
    return
    
END