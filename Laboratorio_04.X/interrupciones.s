;Archivo:	interrupciones.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		12/02/2022
;Ultima modificacion:	16/02/2022
    
        
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
    banksel TMR0	//20ms
    movlw   177
    movwf   TMR0
    bcf	    T0IF
    ENDM

;------------------------------------------------------------------------------
PSECT udata_bank0  
    cont:	DS 1 
    decimales:	DS 1
    unidades:	DS 1
    
    
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
    
    btfsc   T0IF	    //si la bandera esta apagado, skip la siguiente linea
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
    RESET_TMR0		    //btfss revisa si el bit esta encendido, 
    incf    cont	    //skip la siquiente linea
    movf    cont, W
    sublw   50		    //20ms * 50 = 1000ms (1s)
    btfss   ZERO	    //si resta + -> c=1, z=0
    goto    return_tmr0	    //si resta 0 -> c=1, z=1	    
    /*incf    PORTC	    //si resta - -> c=0, z=0
    movlw   0b00001111
    andwf   PORTC*/
    incf    unidades	    //incrementamos la variable
    clrf    cont

return_tmr0:
    return
    
IO_int:
    banksel PORTB	    //chequeamos si el bit esta encendido (por pull-up)
    btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
    incf    PORTD
    btfss   PORTB, 1
    decf    PORTD
    movlw   0b00001111	    //AND para que el puerto sea de 4 bits
    andwf   PORTD
    bcf	    RBIF
    return
    
PSECT code, delta=2, abs
 ORG 100h
 
tabla:
    clrf    PCLATH
    bsf	    PCLATH, 0	;PCLATH = 01
    andwf   0x0f	;me aseguro q solo pasen 4 bits
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
 ;---------------CONFIGURACION--------------------------------------------------

main:
    call    config_ports
    call    config_tmr0
    call    config_int
    call    config_IO
    banksel PORTD
    
;-------------LOOP-------------------------------------------------------------
loop:
    call    unidad	    //donde convertimos a HEX a PORTA
    movf    unidades,W	    //movemos variable a W
    sublw   10		    //10 - w
    btfsc   ZERO	    //si Z=0 skip, 
    call    decimal	    //si z=1, ir a DECIMAL
    
    goto    loop
    
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD	    //puertos A,C,D salida
    clrf    TRISD
    clrf    TRISC
    clrf    TRISA
    
    bsf	    TRISB, 0	    //RB0 y RB1 como entrada
    bsf	    TRISB, 1
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0 y RB1
    bsf	    WPUB, 1
    
    banksel PORTA
    clrf    PORTD
    clrf    PORTC	    
    clrf    PORTA	    //para que Decimal empieze con 0 Hex
    movlw   11111100B	    //0
    movwf   PORTA
    clrf    cont
    clrf    decimales
    clrf    unidades
    return
    
config_IO:
    banksel TRISB	    //configuracion para interrupcion en B
    bsf	    IOCB, 0
    bsf	    IOCB, 1
    
    banksel PORTB	    //mismatch
    movf    PORTB, W
    bcf	    RBIF
    return
   
config_tmr0:
    banksel OSCCON
    bsf	    IRCF2	    //= 1
    bsf	    IRCF1	    //= 1   = 4MHz
    bcf	    IRCF0	    //= 0
    bsf	    SCS
    
    banksel OPTION_REG
    bcf	    T0CS
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0		    //prescaler -> 111= 1:256
    
    RESET_TMR0
    return
    
config_int:
    bsf	    GIE		    //Habilitar interrupciones
    bsf	    RBIE	    //habilitar interrupcion en PORTB
    bcf	    RBIF	    //limpiar bandera
    bcf	    T0IF	    //limpiar bandera tmr0
    bsf	    T0IE	    //habilitar interrupcion en TMR0
    return

unidad:
    movf    unidades, W	    //movemos variable a W
    call    tabla	    //llamamos tabla para comvertir a HEX
    movwf   PORTC	    //y lo movemos al puerto
    return
    
decimal:
    clrf    unidades	    //limpiamos variable
    incf    decimales	    //incrementamos
    movf    decimales, W    //movemos a W
    call    tabla	    //convertir a HEX
    movwf   PORTA	    //mover a puerto
    return
    
END