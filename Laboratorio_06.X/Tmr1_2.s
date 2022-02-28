;Archivo:	Tmr1_2.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		27/02/2022
;Ultima modificacion:	27/02/2022
    
        
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
        
RESET_TMR1 MACRO	    //1s , 8681 = 34433
    MOVLW   0x86	    
    MOVWF   TMR1H	    
    MOVLW   0x81	    
    MOVWF   TMR1L	    
    BCF	    TMR1IF	     
    ENDM

;------------------------------------------------------------------------------
PSECT udata_bank0  
    cont:	DS 1
    cont2:	DS 1
    cont3:
    
PSECT udata_shr
    W_TEMP:	DS 1
    STATUS_TEMP:DS 1
    
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
    btfsc   TMR1IF	    //si la bandera esta apagado, skip la siguiente linea
    call    T1_int
    
    btfsc   TMR2IF
    call    T2_int
    
POP:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

;----------------Subrutinas de Interrupcion ------------------------------------

T1_int:
    RESET_TMR1
    incf    cont
    return
    
T2_int:
    bcf	    TMR2IF
    incf    cont2
    movf    cont2, W
    sublw   2		//250ms * 2 = 500ms
    btfss   ZERO
    goto    return_tmr2
    bsf	    PORTA, 0
    clrf    cont2
    
    incf    cont3
    movf    cont3, W
    sublw   2		//250ms * 2 = 500ms
    btfss   ZERO
    goto    return_tmr2
    bcf	    PORTA, 0
    clrf    cont3
    
return_tmr2:
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
    call    reloj
    call    config_tmr1
    call    config_tmr2
    call    config_int
    banksel PORTD

;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    movf    cont, W
    movwf   PORTC
    goto loop
    
    
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD	    
    clrf    TRISC
    clrf    TRISA
    
    banksel PORTA	    
    clrf    PORTC
    clrf    PORTA
    
    return
    
reloj:
    banksel OSCCON
    bsf	    IRCF2   //1
    bcf	    IRCF1   //0 = 1MHz
    bcf	    IRCF0   //1
    bsf	    SCS	   
    return
    
config_tmr1:
    banksel T1CON
    bcf	    TMR1GE	//tmr1 siempre cuenta
    bsf	    T1CKPS1	//prescaler
    bsf	    T1CKPS0	//1:8
    
    bcf	    T1OSCEN	//LP deshabilitado
    bcf	    TMR1CS	//reloj interno 
    bsf	    TMR1ON
    
    RESET_TMR1
    return
    
config_int:
    banksel PIE1
    bsf	    TMR1IE	    //interrupcion TMR1
    bsf	    TMR2IE	    //interrupcion TMR2
    
    banksel INTCON
    bsf	    PEIE
    bsf	    GIE		    //Habilitar interrupciones
    bsf	    RBIE	    //habilitar interrupcion en PORTB
    bcf	    RBIF	    //limpiar bandera
    //bcf	    T0IF	    //limpiar bandera tmr0
    //bsf	    T0IE	    //habilitar interrupcion en TMR0
    bcf	    TMR1IF
    bcf	    TMR2IF
    return

config_tmr2:
    banksel PR2
    movlw   244		    //250ms
    movwf   PR2
    
    banksel T2CON
    bsf	    T2CKPS1	    //prescaler 1:16
    bsf	    T2CKPS0
    
    bsf	    TOUTPS3	    //postscaler 1:16
    bsf	    TOUTPS2
    bsf	    TOUTPS1
    bsf	    TOUTPS0
    
    bsf	    TMR2ON  
    return
    