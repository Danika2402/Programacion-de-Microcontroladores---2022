;Archivo:	Timer.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		16/03/2022
;Ultima modificacion:	19/03/2022
    
        
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
    banksel TMR0	//2ms
    movlw   254
    movwf   TMR0
    bcf	    T0IF
ENDM
    
RESET_TMR1 MACRO	    //1s , 85EE = 34286	
    movlw   0x85	    //0XF9   
    movwf   TMR1H	    
    movlw   0xEE	    //0X0D    
    movwf   TMR1L	    
    bcf	    TMR1IF	     
ENDM

;------------------------------------------------------------------------------
PSECT udata_bank0  
    segundos_timer:	DS 2
    minutos_timer:	DS 2
    dividir:		DS 1
    alarma:		DS 1
    
    parar_timer:	DS 1
    apagar_led:		DS 1
    
    Editar_Aceptar: DS 1
    //Display_Up:	    DS 1
    //Display_Down:   DS 1
    
    banderas:	DS 1	; Indica que display hay que encender
    nibbles:	DS 4	; Contiene los nibbles alto y bajo de "valor"
    display:	DS 4	; Representación de cada nibble en el display
    
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
    btfsc   RBIF
    call    IO_int
    
    btfsc   T0IF	    //si la bandera esta apagado, skip la siguiente linea
    call    TO_int
    
    btfsc   TMR1IF	    //si la bandera esta apagado, skip la siguiente linea
    call    T1_int

POP:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

;----------------Subrutinas de Interrupcion ------------------------------------

TO_int:
    RESET_TMR0
    call    MOSTRAR_VALOR
    return
    
T1_int:
    RESET_TMR1
    //incf    segundos_timer
    //incf    minutos
    /*movf    alarma, W
    subwf   1
    btfss   ZERO
    decf    segundos_timer*/
    
    movf    alarma, W
    sublw   1
    btfsc   ZERO	    //si Z=0 skip
    decf    segundos_timer
    
    movf    parar_timer, W
    sublw   1
    btfsc   ZERO
    call    LED_1MINUTO
    return
    
IO_int:
    banksel PORTB
    btfss   PORTB, 2
    incf    Editar_Aceptar
    
    btfss   PORTB, 3
    incf    alarma
    
    bcf	    RBIF
    call    EDITAR_TIMER
    
    return
    
PSECT code, delta=2, abs
 ORG 100h
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


;---------------CONFIGURACION--------------------------------------------------

main:
    call    config_ports
    call    reloj
    call    config_tmr0
    call    config_tmr1
    call    config_int
    banksel PORTD
;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    call    DISPLAY_SET
    call    NIBBLE_TIMER
    call    TIMER_DIGITOS
    call    UNDERFLOW_TIMER
    call    INICIAR_ALARMA
    
    goto    loop
    
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD	    
    clrf    TRISC
    clrf    TRISA
    clrf    TRISE
    
    bcf	    TRISD, 0
    bcf	    TRISD, 1	    //bits de PORTD como salida
    bcf	    TRISD, 2
    bcf	    TRISD, 3
    
    bsf	    TRISB, 0	    //DISPLAY_UP
    bsf	    TRISB, 1	    //DISPLAY_DOWN
    bsf	    TRISB, 2	    //EDITAR/ACEPTAR
    bsf	    TRISB, 3	    //INICIAR/ACEPTAR
    //bsf	    TRISB, 4	    //MODO
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0 y RB1
    bsf	    WPUB, 1
    bsf	    WPUB, 2
    bsf	    WPUB, 3
    //bsf	    WPUB, 4
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    clrf    segundos_timer
    clrf    minutos_timer
    clrf    alarma
    return
    
reloj:
    banksel OSCCON
    bsf	    IRCF2   //1
    bcf	    IRCF1   //0 = 1MHz
    bcf	    IRCF0   //0
    bsf	    SCS	   
    return
    
config_tmr0:
    banksel OPTION_REG
    bcf	    T0CS
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0		    //prescaler -> 111= 1:256
    
    RESET_TMR0
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
    //bsf	    TMR2IE	    //interrupcion TMR2
    
    banksel TRISB	    //configuracion para interrupcion en B
    bsf	    IOCB, 0	    //DISPLAY UP/INCREMENTAR
    bsf	    IOCB, 1	    //DISPLAY DOWN/DECREMENTAR
    bsf	    IOCB, 2	    //EDITAR/ACEPTAR
    bsf	    IOCB, 3	    //INICIAR/PARAR
    //bsf	    IOCB, 4	    //MODO
    
    banksel PORTB	    //mismatch
    movf    PORTB, W
    
    banksel INTCON
    bsf	    PEIE
    bsf	    GIE		    //Habilitar interrupciones
    bsf	    RBIE	    //habilitar interrupcion en PORTB
    bcf	    RBIF	    //limpiar bandera
    bcf	    T0IF	    //limpiar bandera tmr0
    bsf	    T0IE	    //habilitar interrupcion en TMR0
    bcf	    TMR1IF	    //bandera en TMR1
    //bcf	    TMR2IF
    return
    
DISPLAY_SET:
    
    movf    nibbles, W
    call    tabla
    movwf   display
    
    movf    nibbles+1, W
    call    tabla
    movwf   display+1
    
    movf    nibbles+2, W
    call    tabla
    movwf   display+2
    
    movf    nibbles+3, W
    call    tabla
    movwf   display+3
    return

NIBBLE_TIMER:
    movf    segundos_timer, W
    movwf   nibbles
    
    movf    segundos_timer+1, W
    movwf   nibbles+1
    
    movf    minutos_timer, W
    movwf   nibbles+2
    
    movf    minutos_timer+1, W
    movwf   nibbles+3
    return

MOSTRAR_VALOR:
    clrf    PORTD
    btfss   banderas, 1	    //limpiamos PORTD y dependiendo de la bandera,
    goto    display_0	    //vamos a una subtutina
    
    btfss   banderas, 0
    goto    display_1
    
    btfss   banderas, 2
    goto    display_2
    
    btfss   banderas, 3
    goto    display_3
    
    display_0:
	movf	display, W	//aqui movemos lo que esta en display a W
	movwf	PORTC		//y eso lo movemos al PORTC donde esta el display
	bsf	PORTD, 0	//y encendemos el bit de PORTD
	bsf	banderas, 1	//donde el display esta conectado
	return

    display_1:
	movf	display+1, W
	movwf	PORTC
	bsf	PORTD, 1 
	bsf	banderas, 0
	return

    display_2:
	bsf	banderas, 2
	movf	display+2, W
	movwf	PORTC
	bsf	PORTD, 2
	return
    
    display_3:
	clrf	banderas
	movf	display+3, W
	movwf	PORTC
	bsf	PORTD, 3
	return
    
EDITAR_TIMER:
    
    movf    Editar_Aceptar, W
    sublw   1		
    btfsc   ZERO			    //si Z=0 skip
    goto    MODIFICAR_MINUTOS_TIMER	    //si Z=1 ir a MODIFICAR_MINUTOS
    
    movf    Editar_Aceptar, W
    sublw   2		
    btfsc   ZERO			    //si Z=0 skip
    goto    MODIFICAR_SEGUNDOS_TIMER	    //si Z=1 ir a MODIFICAR_HORAS
    
    movf    Editar_Aceptar, W
    sublw   3		
    btfsc   ZERO			     //si Z=0 skip
    clrf    Editar_Aceptar
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    
    return
    
    MODIFICAR_MINUTOS_TIMER:
	banksel PORTB
	bcf	PORTE,0
	bsf	PORTE,1

	btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
	incf	minutos_timer
	btfss   PORTB, 1
	decf	minutos_timer
	bcf	RBIF

	return

    MODIFICAR_SEGUNDOS_TIMER: 
	banksel PORTB
	bsf	PORTE,0
	bcf	PORTE,1
	
	btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
	incf    segundos_timer
	btfss   PORTB, 1
	decf    segundos_timer
	bcf	RBIF
	return

LED_1MINUTO:
    bsf	PORTE,2
    incf    apagar_led
    return
	
TIMER_DIGITOS:
    movf    segundos_timer+1, W 
    movwf   dividir
    movlw   6
    subwf   dividir, F
    btfss   ZERO
    goto    $+3
    clrf    segundos_timer+1
    incf    minutos_timer
    clrf    dividir
    
    movf    segundos_timer, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	   
    goto    $+3		   
    clrf    segundos_timer
    incf    segundos_timer+1
    clrf    dividir
    
    movf    minutos_timer, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	    
    goto    $+3		    
    clrf    minutos_timer
    incf    minutos_timer+1
    clrf    dividir
    
    movf    minutos_timer+1,W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfsc   ZERO
    goto    REINICIO_TIMER
    clrf    dividir
    return
    
    
UNDERFLOW_TIMER:			
    movf    segundos_timer, W	    //si resta +,0 -> c = 1
    movwf   dividir
    movlw   255		    //si resta - -> c = 0
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    clrf    segundos_timer
    decf    segundos_timer+1
    movlw   9
    addwf   segundos_timer
    clrf    dividir
    
    movf    segundos_timer+1, W	    //si resta +,0 -> c = 1
    movwf   dividir
    movlw   255		    //si resta - -> c = 0
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    decf    minutos_timer
    clrf    segundos_timer+1
    movlw   5
    addwf   segundos_timer+1
    clrf    dividir
    
    movf    minutos_timer, W	    //si resta +,0 -> c = 1
    movwf   dividir
    movlw   255		    //si resta - -> c = 0
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    clrf    minutos_timer
    decf    minutos_timer+1
    movlw   9
    addwf   minutos_timer
    clrf    dividir
    
    movf    minutos_timer+1, W	    //si resta +,0 -> c = 1
    movwf   dividir
    movlw   255		    //si resta - -> c = 0
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+4
    clrf    minutos_timer+1
    movlw   9
    addwf   minutos_timer+1
    clrf    dividir
				
    
    return

REINICIO_TIMER:
    clrf    segundos_timer
    clrf    minutos_timer
    clrf    segundos_timer+1
    clrf    minutos_timer+1
    clrf    nibbles
    clrf    nibbles+1
    clrf    nibbles+2
    clrf    nibbles+3
    return

    
INICIAR_ALARMA:
    movf    alarma, W
    movwf   dividir
    movlw   1
    subwf   dividir, F
    btfss   ZERO
    goto    $+32
    clrf    dividir
    
	movf	minutos_timer+1, W
	movwf	dividir
	movlw	0
	subwf	dividir, F
	btfss	ZERO
	goto	$+25
	clrf	dividir
	
	    movf	minutos_timer, W
	    movwf	dividir
	    movlw	0
	    subwf	dividir, F
	    btfss	ZERO
	    goto	$+18
	    clrf	dividir

		movf	segundos_timer+1, W
		movwf	dividir
		movlw	0
		subwf	dividir, F
		btfss	ZERO
		goto	$+11
		clrf	dividir

		    movf	segundos_timer, W
		    movwf	dividir
		    movlw	0
		    subwf	dividir, F
		    btfss	ZERO
		    goto	$+4
		    call	REINICIO_TIMER
		    incf    	alarma
		    incf	parar_timer
		    clrf	dividir
    
		    
		    
    movf    alarma, W
    movwf   dividir
    movlw   3
    subwf   dividir, F
    btfss   ZERO	    
    goto    $+5
    bcf	    PORTE, 2
    clrf    apagar_led
    clrf    parar_timer
    clrf    alarma
    clrf    dividir
    
    movf    apagar_led, W
    movwf   dividir
    movlw   60
    subwf   dividir, F
    btfss   ZERO
    goto    $+5
    bcf	    PORTE, 2
    clrf    apagar_led
    clrf    parar_timer
    clrf    alarma
    clrf    dividir
    return