;Archivo:	Tmr0.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:	31/01/2022
;Ultima modificacion: 31/01/2022
    
    
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
    CALL    CONFIG_PORTS
    call config_reloj
    call config_tmr0
    
loop:
    btfss   T0IF
    goto    $-1
    
    CALL    reinicio_tmr0   ; Reinicio del TMR0
    INCF    PORTD	    ; Incrementamos en 1 el PORTD (Extra de lo visto en clase)
    GOTO    loop
    
;-----------sub rutinas--------------------------------------------------------
    
CONFIG_PORTS:
    BANKSEL ANSEL	    ; Cambio de banco
    CLRF    ANSEL	    ; I/O digitales
    CLRF    ANSELH	    ; I/O digitales
    BANKSEL TRISD
    CLRF    TRISD	    ; PORTD como salida
    BANKSEL PORTD   
    CLRF    PORTD	    ; APAGAR PORTD 
    RETURN
    
config_reloj:
    banksel OSCCON
    bsf	    SCS	 //reloj interno	
    bsf	    IRCF2   
    bsf	    IRCF1
    bcf	    IRCF0   //4MHZ = 110
    return
    
config_tmr0:
    banksel OPTION_REG
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0	    //prescaler 1:256 = 111
    bcf	    T0CS	//reloj interno
    
    call    reinicio_tmr0
    return
    
reinicio_tmr0:
    banksel TMR0
    movlw   61	    //50ms, se carga valor inicial
    movwf   TMR0
    bcf	    T0IF    //limpiar bandera
    return