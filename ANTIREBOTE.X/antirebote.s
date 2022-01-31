;Archivo:	antirebote.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
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
    bsf	    STATUS,5	;banco 01
    bsf	    STATUS, 6	;banco 11
    clrf    ANSEL
    clrf    ANSELH
    
    bcf	    STATUS,6	;BANCO 01   
    bsf	    TRISA, 0
    clrf    TRISB
    bcf	    STATUS, 5
    clrf    PORTB
    
CHECKBOTON:
    btfsc   PORTA, 0
    goto    CHECKBOTON
    
ANTIREBOTE:
    btfss   PORTA,0
    goto    ANTIREBOTE
    
    incf    PORTB, F
    goto    CHECKBOTON
    
END
