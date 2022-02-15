;Archivo:	interrupciones.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		12/02/2022
;Ultima modificacion:	12/02/2022
    
        
PROCESSOR 16F887
#include <xc.inc>
    
CONFIG FOSC  =   INTRC_NOCLKOUT
CONFIG WDTE  =   OFF
CONFIG PWRTE =   OFF
CONFIG MCLRE =   OFF
CONFIG CP    =   OFF
CONFIG CPD   =   OFF
    
CONFIG BOREN =   OFF
CONFIG IESO  =   OFF
CONFIG FCMEN =   OFF
CONFIG LVP   =   OFF
    
CONFIG WRT   =   OFF
CONFIG BOR4V =   BOR40V
        
RESET_TMR0 MACRO 
    banksel TMR0
    movlw   177
    movwf   TMR0
    bcf	    T0IF
    ENDM

;------------------------------------------------------------------------------
PSECT udata_bank0  
    cont:   DS 1 
    
PSECT udata_shr
    W_TEMP:		DS 1
    STATUS_TEMP:	DS 1
    
PSECT resVect, class=CODE,abs, delta=2
;-----------------Vector Reset--------------------------------------------------
ORG 00h
resetVec:
    PAGESEL main
    goto main
	
PSECT intVect, class=CODE, abs, delta=2
 ORG 04h
;----------------Vector Interrupciones------------------------------------------    

PUSH:
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   STATUS_TEMP
    
ISR:
    
    btfsc   T0IF
    call    TO_int
    
    btfsc   RBIF
    call    IO_int
    
   // RESET_TMR0 
    //incf    PORTC
    
POP:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

;----------------Subrutinas de Interrupcion ------------------------------------

TO_int:
    RESET_TMR0	
    //incf    PORTC	    //btfss revisa si el bit esta encendido, 
    incf    cont	    //skip la siquiente linea
    movf    cont, W
    sublw   50		    //20ms * 50 = 1000ms (1s)
    btfss   ZERO	    //si resta + -> c=1, z=0
    goto    return_tmr0	    //si resta 0 -> c=1, z=1
    movf    cont, W	    //si resta - -> c=0, z=0
    incf    PORTC
    movlw   0b00001111
    andwf   PORTC
    clrf    cont

return_tmr0:
    return
    
IO_int:
    banksel PORTB
    btfss   PORTB, 0
    incf    PORTD
    btfss   PORTB, 1
    decf    PORTD
    movlw   0b00001111
    andwf   PORTD
    bcf	    RBIF
    return
    
PSECT code, delta=2, abs
 ORG 100h
 ;---------------CONFIGURACION--------------------------------------------------

main:
    call    config_ports
    call    config_tmr0
    call    config_int
    call    config_IO
    banksel PORTD
    
;-------------LOOP-------------------------------------------------------------
loop:
    goto    loop
    
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD
    clrf    TRISD
    clrf    TRISC
    
    bsf	    TRISB, 0
    bsf	    TRISB, 1
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0
    bsf	    WPUB, 1
    
    banksel PORTA
    clrf    PORTD
    clrf    PORTC
    clrf    cont
    return
    
config_IO:
    banksel TRISB
    bsf	    IOCB, 0
    bsf	    IOCB, 1
    
    banksel PORTB
    movf    PORTB, W
    bcf	    RBIF
    return
   
config_tmr0:
    banksel OSCCON
    bsf	    IRCF2   //= 1
    bsf	    IRCF1   //= 1   = 4MHz
    bcf	    IRCF0   //= 0
    bsf	    SCS
    
    banksel OPTION_REG
    bcf	    T0CS
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0	    //prescaler -> 111= 1:256
    
    RESET_TMR0
    return
    
config_int:
    bsf	    GIE
    bsf	    RBIE
    bcf	    RBIF
    bcf	    T0IF
    bsf	    T0IE
    return
    
END