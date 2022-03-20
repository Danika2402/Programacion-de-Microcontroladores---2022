;Archivo:	Reloj_digital.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		05/03/2022
;Ultima modificacion:	05/03/2022
    
        
PROCESSOR 16F887
#include <xc.inc>
#include "Macros.inc"

    
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
    
GLOBAL	tabla
GLOBAL	modo,dividir
GLOBAL	config_ports,reloj,config_tmr0,config_tmr1,config_tmr2,config_int
GLOBAL	W_TEMP,STATUS_TEMP
    
GLOBAL	MOSTRAR_VALOR, DISPLAY_SET
GLOBAL	NIBBLE_RELOJ, NIBBLE_FECHA, NIBBLE_TIMER
    
GLOBAL	TO_int, T2_int
GLOBAL	T1_RELOJ, IO_RELOJ
GLOBAL	IO_FECHAS
GLOBAL	T1_TIMER, IO_TIMER
    
GLOBAL	Reloj_Digitos, UN_DIA, UNDERFLOW_RELOJ
GLOBAL	Fecha_digitos, UNDERFLOW_FECHA, MESES    
GLOBAL	TIMER_DIGITOS, UNDERFLOW_TIMER, INICIAR_ALARMA
    
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
    btfsc   RBIF
    call    IO_int
    
    btfsc   T0IF	    //si la bandera esta apagado, skip la siguiente linea
    call    TO_int
    
    //btfsc   TMR1IF	    //si la bandera esta apagado, skip la siguiente linea
    //call    T1_int
    
    //btfsc   TMR2IF
    //call    T2_int

POP:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie
    
;------------Subrutinas de interrupcion-----------------------------------------
IO_int:
    btfss   PORTB, 4
    incf    modo
    bcf	    RBIF
    return
    
 T1_int:
    
    return

PSECT code, delta=2, abs
 ORG 100h
;---------------CONFIGURACION--------------------------------------------------
main:
    call    config_ports
    call    reloj
    call    config_tmr0
//    call    config_tmr1
    call    config_tmr2
    call    config_int
    banksel PORTD
;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    call    DISPLAY_SET
    
    movf    modo, W
    movwf   dividir
    sublw   0
    btfss   ZERO
    goto    ESTADO_1
    clrf    dividir
    
    movf    modo, W
    movwf   dividir
    sublw   1
    btfss   ZERO
    goto    ESTADO_2
    clrf    dividir
    
    movf    modo, W
    movwf   dividir
    sublw   2
    btfss   ZERO
    goto    ESTADO_3
    clrf    dividir
    
    movf    modo, W
    movwf   dividir
    sublw   3
    btfss   ZERO
    goto    ESTADO_4
    clrf    dividir
    
    goto    loop
    
ESTADO_1:
    bsf	    PORTA,0
    bcf	    PORTA,1
    bcf	    PORTA,2
    return
    
ESTADO_2:
    bcf	    PORTA,0
    bsf	    PORTA,1
    bcf	    PORTA,2
    return
    
ESTADO_3:
    bcf	    PORTA,0
    bcf	    PORTA,1
    bsf	    PORTA,2
    return
    
ESTADO_4:
    bcf	    PORTA,0
    bcf	    PORTA,1
    bcf	    PORTA,2
    clrf    modo
    return
    
tabla:
    clrf    PCLATH
    bsf	    PCLATH, 0	;PCLATH = 01
    andlw   0x0f	;me aseguro q solo pasen 4 bits
    addwf   PCL		;PC = PCL + PCLATH + w
    retlw   11111100B	;0  
    retlw   01100000B	;1  
    retlw   11011010B	;2  
    retlw   11110010B	;3  
    retlw   01100110B	;4  
    retlw   10110110B	;5  
    retlw   10111110B	;6  
    retlw   11100000B	;7  
    retlw   11111110B	;8  
    retlw   11110110B	;9  
    retlw   11101110B	;A  
    retlw   00111110B	;B  
    retlw   10011100B	;C  
    retlw   01111010B	;D  
    retlw   10011110B	;E  
    retlw   10001110B	;F  
     
END