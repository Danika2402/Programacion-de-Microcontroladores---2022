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
    banksel TMR0	//1ms
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
PSECT udata_shr
    W_TEMP:	DS 1
    STATUS_TEMP:DS 1	
    
PSECT udata_bank0
    //variables RELOJ DIGITAL
    segundos:	DS 1
    minutos:	DS 2
    horas:	DS 2
    
    //variables FECHAS
    mes:	    DS 1
    dias:	    DS 2
    dividir_mes:    DS 2
    
    //variables TIMER
    segundos_timer:	DS 2
    minutos_timer:	DS 2
    alarma:		DS 1
    parar_timer:	DS 1
    apagar_led:		DS 1
    
    //Variables generales
    Editar_Aceptar: DS 1
    dividir:	    DS 1
    
    cont1:	DS 1
    modo:	DS 1
    
    banderas:	DS 1	; Indica que display hay que encender
    nibbles:	DS 4	; Contiene los nibbles alto y bajo de "valor"
    display:	DS 4	; Representación de cada nibble en el display
   
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
    
    btfsc   TMR2IF
    call    T2_int
    
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
    incf    segundos	    //segundos del Reloj digital
    
    //
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
    
    btfsc   PORTB, 4
    goto    $+3
    clrf    Editar_Aceptar
    incf    modo
    
    bcf	    RBIF
    call    EDITAR
    return
    
T2_int:
    bcf	    TMR2IF
    incf    cont1
    return

////////////////////////////////////////////////////////////////////////////////
    
LED_1MINUTO:
    bsf	    PORTE,2
    incf    apagar_led
    return
    
EDITAR:
    
    movf    modo, W
    sublw   0
    btfsc   ZERO
    goto    EDITAR_RELOJ
    
    movf    modo, W
    sublw   1
    btfsc   ZERO
    goto    EDITAR_FECHA
    
    movf    modo, W
    sublw   2
    btfsc   ZERO
    goto    EDITAR_TIMER
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    
    return
    
////////////////////////////////////////////////////////////////////////////////    
    
EDITAR_RELOJ:
    //si resta + -> c=1, z=0
    //si resta 0 -> c=1, z=1	    
    //si resta - -> c=0, z=0
    
    movf    Editar_Aceptar, W
    sublw   1		
    btfsc   ZERO		    //si Z=0 skip
    goto    MODIFICAR_MINUTOS	    //si Z=1 ir a MODIFICAR_MINUTOS
    
    movf    Editar_Aceptar, W
    sublw   2		
    btfsc   ZERO		    //si Z=0 skip
    goto    MODIFICAR_HORAS	    //si Z=1 ir a MODIFICAR_HORAS
    
    movf    Editar_Aceptar, W
    sublw   3		
    btfsc   ZERO		    //si Z=0 skip
    clrf    Editar_Aceptar	    
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    return

    MODIFICAR_HORAS:
	banksel PORTB
	bcf	PORTE,0
	bsf	PORTE,1
	bcf	PORTE,2
	clrf    segundos

	btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
	incf    horas
	btfss   PORTB, 1
	decf    horas
	bcf	RBIF
	return

    MODIFICAR_MINUTOS: 
	banksel PORTB
	bsf	PORTE,0
	bcf	PORTE,1
	bcf	PORTE,2
	clrf    segundos

	btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
	incf    minutos
	btfss   PORTB, 1
	decf    minutos
	bcf	RBIF
	return
    
EDITAR_FECHA:
    
    movf    Editar_Aceptar, W
    sublw   1		
    btfsc   ZERO		    //si Z=0 skip
    goto    MODIFICAR_MESES	    //si Z=1 ir a MODIFICAR_MINUTOS
    
    movf    Editar_Aceptar, W
    sublw   2		
    btfsc   ZERO		    //si Z=0 skip
    goto    MODIFICAR_DIAS	    //si Z=1 ir a MODIFICAR_HORAS
    
    movf    Editar_Aceptar, W
    sublw   3		
    btfsc   ZERO		    //si Z=0 skip
    clrf    Editar_Aceptar	    
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    
    return
    
    MODIFICAR_MESES:
	banksel PORTB
	bcf	PORTE,0
	bsf	PORTE,1
	bcf	PORTE,2

	btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
	incf	mes
	btfss   PORTB, 1
	decf	mes
	bcf	RBIF

	return

    MODIFICAR_DIAS: 
	banksel PORTB
	bsf	PORTE,0
	bcf	PORTE,1
	bcf	PORTE,2

	btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
	incf    dias
	btfss   PORTB, 1
	decf    dias
	bcf	RBIF
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

	
////////////////////////////////////////////////////////////////////////////////
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
    call    config_tmr2
    call    config_int
    banksel PORTD
;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    call    TMR2_LED
    call    DISPLAY_SET
    
    movf    modo, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_1
    clrf    dividir
    
    movf    modo, W
    movwf   dividir
    movlw   1
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_2
    clrf    dividir
    
    movf    modo, W
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_3
    clrf    dividir
    
    movf    modo, W
    movwf   dividir
    movlw   3
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_4
    clrf    dividir
    goto    loop
    
//////////////////////////////////////////////////////////////////////////////// 
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
    bsf	    TRISB, 4	    //MODO
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0 y RB1
    bsf	    WPUB, 1
    bsf	    WPUB, 2
    bsf	    WPUB, 3
    bsf	    WPUB, 4
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    
    clrf    Editar_Aceptar
    clrf    dividir
    clrf    cont1
    clrf    modo
    
    clrf    segundos
    clrf    minutos
    clrf    horas
    
    clrf    mes
    clrf    dias
    clrf    dividir_mes
    
    clrf    segundos_timer 
    clrf    minutos_timer
    clrf    alarma
    clrf    parar_timer
    clrf    apagar_led
    
    movlw   1
    movwf   dias
    
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
    
config_int:
    banksel PIE1
    bsf	    TMR1IE	    //interrupcion TMR1
    bsf	    TMR2IE	    //interrupcion TMR2
    
    banksel TRISB	    //configuracion para interrupcion en B
    bsf	    IOCB, 0	    //DISPLAY UP/INCREMENTAR
    bsf	    IOCB, 1	    //DISPLAY DOWN/DECREMENTAR
    bsf	    IOCB, 2	    //EDITAR/ACEPTAR
    bsf	    IOCB, 3	    //INICIAR/PARAR
    bsf	    IOCB, 4	    //MODO
    
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
    bcf	    TMR2IF
    return
////////////////////////////////////////////////////////////////////////////////
    
TMR2_LED:
    movf    cont1, W
    sublw   2		//250ms * 2 = 500ms
    btfsc   ZERO
    bsf	    PORTC, 0

    movf    cont1, W
    sublw   4		//250ms * 2 = 500ms
    btfss   ZERO
    goto    $+3
    bcf	    PORTC, 0
    clrf    cont1
    
    return
    
MOSTRAR_VALOR:
    clrf    PORTD
    btfss   banderas, 0	    //limpiamos PORTD y dependiendo de la bandera,
    goto    display_0	    //vamos a una subtutina
    
    btfss   banderas, 1
    goto    display_1
    
    btfss   banderas, 2
    goto    display_2
    
    btfss   banderas, 3
    goto    display_3
    
    display_0:
	movf	display, W	//aqui movemos lo que esta en display a W
	movwf	PORTC		//y eso lo movemos al PORTC donde esta el display
	bsf	PORTD, 0	//y encendemos el bit de PORTD
	bsf	banderas, 0	//donde el display esta conectado
	return

    display_1:
	movf	display+1, W
	movwf	PORTC
	bsf	PORTD, 1 
	bsf	banderas, 1
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
    
////////////////////////////////////////////////////////////////////////////////
    
NIBBLE_RELOJ:
    movf    minutos, W
    movwf   nibbles
    
    movf    minutos+1, W
    movwf   nibbles+1
    
    movf    horas, W
    movwf   nibbles+2
    
    movf    horas+1, W
    movwf   nibbles+3
    return
    
NIBBLE_FECHA:
    movf    dias, W
    movwf   nibbles
    
    movf    dias+1, W
    movwf   nibbles+1
    
    movf    dividir_mes, W
    movwf   nibbles+2
    
    movf    dividir_mes+1, W
    movwf   nibbles+3
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
    
////////////////////////////////////////////////////////////////////////////////
ESTADO_1:
    bsf	    PORTA,0
    bcf	    PORTA,1
    bcf	    PORTA,2
    
    call    NIBBLE_RELOJ
    call    Reloj_Digitos
    call    UN_DIA
    call    UNDERFLOW_RELOJ
    
    return
    
ESTADO_2:
    bcf	    PORTA,0
    bsf	    PORTA,1
    bcf	    PORTA,2
    
    call    UNDERFLOW_FECHA
    movf    mes, W
    call    MESES
    
    call    NIBBLE_FECHA
    call    Fecha_digitos
    
    return
    
ESTADO_3:
    bcf	    PORTA,0
    bcf	    PORTA,1
    bsf	    PORTA,2
    call    NIBBLE_TIMER
    call    TIMER_DIGITOS
    call    UNDERFLOW_TIMER
    call    INICIAR_ALARMA
    
    return
    
ESTADO_4:
    bcf	    PORTA,0
    bcf	    PORTA,1
    bcf	    PORTA,2
    clrf    modo
    clrf    Editar_Aceptar
    
    clrf    nibbles
    clrf    nibbles+1
    clrf    nibbles+2
    clrf    nibbles+3
    
    return
    
////////////////////////////////////////////////////////////////////////////////
    
;*******************************************************************************
;----------------RELOJ DIGITAL--------------------------------------------------
;*******************************************************************************   

Reloj_Digitos:

    movf    segundos, W	    
    movwf   dividir
    movlw   60		    
    subwf   dividir, F	    
    btfss   ZERO	    	    
    goto    $+3
    clrf    segundos
    incf    minutos
    clrf    dividir
    
    movf    minutos, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	    
    goto    $+3		    
    clrf    minutos
    incf    minutos+1
    clrf    dividir
  
    movf    minutos+1, W
    movwf   dividir
    movlw   6		    
    subwf   dividir, F	    
    btfss   ZERO	    
    goto    $+3
    clrf    minutos+1
    incf    horas
    clrf    dividir
    
    movf    horas, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	   
    goto    $+3		   
    clrf    horas
    incf    horas+1
    clrf    dividir
    
    return
    
UN_DIA:
    movf    horas+1, W
    movwf   dividir	    //si resta + -> Z = 0
    movlw   2	    	    //si resta 0 -> Z = 1
    subwf   dividir, F	    //si resta - -> Z = 0
    btfss   ZERO	    // si Z=1 skip
    goto    $+7   

    movf    horas, W
    movwf   dividir	    
    movlw   4	    	    
    subwf   dividir, F	    
    btfsc   ZERO	    // si Z=0 skip
    call    REINICIO_reloj
    clrf    dividir
    return

REINICIO_reloj:
    incf    dias
    clrf    segundos
    clrf    minutos
    clrf    horas
    clrf    segundos+1
    clrf    minutos+1
    clrf    horas+1
    clrf    nibbles
    clrf    nibbles+1
    clrf    nibbles+2
    clrf    nibbles+3
    return

UNDERFLOW_RELOJ:
				
    movf    minutos, W	    //si resta +,0 -> c = 1
    movwf   dividir
    movlw   255		    //si resta - -> c = 0
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    clrf    minutos
    decf    minutos+1
    movlw   9
    addwf   minutos
    clrf    dividir
    
    movf    minutos+1, W
    movwf   dividir
    movlw   255	    
    subwf   dividir,F
    btfss   CARRY
    goto    $+4
    clrf    minutos+1
    movlw   5
    addwf   minutos+1
    clrf    dividir
    
    movf    horas, W	    //si resta +,0 -> c = 1
    movwf   dividir
    movlw   255		    //si resta - -> c = 0
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    clrf    horas
    decf    horas+1
    movlw   9
    addwf   horas
    clrf    dividir
    
    movf    horas+1, W
    movwf   dividir
    movlw   255	    
    subwf   dividir,F
    btfss   CARRY	    
    goto    $+7
    clrf    horas+1
    clrf    horas
    movlw   2
    addwf   horas+1
    movlw   3
    addwf   horas
    clrf    dividir

    return
    
    
;*******************************************************************************
;----------------FECHA----------------------------------------------------------
;*******************************************************************************
    
Fecha_digitos:
    
    movf    dividir_mes,W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	//si z=0 skip
    goto    $+3
    clrf    dividir_mes
    incf    dividir_mes+1
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO
    goto    $+3
    clrf    dias
    incf    dias+1
    clrf    dividir
    return    
  
UNDERFLOW_FECHA:
    movf    dias, W
    movwf   dividir
    movlw   255
    subwf   dividir, F
    btfss   ZERO
    goto    $+5
    clrf    dias
    decf    dias+1
    movlw   9
    addwf   dias
    clrf    dividir
    
    movf    mes,W
    movwf   dividir
    movlw   255
    subwf   dividir, F
    btfss   ZERO
    goto    $+4
    clrf    mes
    movlw   11
    addwf   mes
    clrf    dividir
    return

DIAS_30:
    movf    dias+1, W
    movwf   dividir
    movlw   3
    subwf   dividir, F
    btfss   CARRY
    goto    $+13
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   1
    subwf   dividir, F
    btfss   CARRY    
    goto    $+6
    incf    mes
    clrf    dias
    clrf    dias+1
    movlw   1
    addwf   dias
    clrf    dividir
    
    movf    dias+1, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfss   ZERO
    goto    $+12
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfss   ZERO
    goto    $+5
    clrf    dias+1
    clrf    dias
    movlw   3
    addwf   dias+1
    clrf    dividir
    
    return
    
DIAS_31:
    movf    dias+1, W
    movwf   dividir
    movlw   3
    subwf   dividir, F
    btfss   CARRY	
    goto    $+13
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfss   CARRY    
    goto    $+6
    incf    mes
    clrf    dias
    clrf    dias+1
    movlw   1
    addwf   dias
    clrf    dividir
    
    movf    dias+1, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfss   ZERO
    goto    $+14
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfss   ZERO
    goto    $+7
    clrf    dias+1
    clrf    dias
    movlw   3
    addwf   dias+1
    movlw   1
    addwf   dias
    clrf    dividir
    return


ENERO:
    clrf    dividir_mes+1
    movlw   1
    movwf   dividir_mes
    
    call    DIAS_31
    return

FEBRERO:
    clrf    dividir_mes+1
    movlw   2
    movwf   dividir_mes
    
    movf    dias+1, W
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfss   CARRY
    goto    $+13
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   9
    subwf   dividir, F
    btfss   CARRY   
    goto    $+6
    incf    mes
    clrf    dias
    clrf    dias+1
    movlw   1
    addwf   dias
    clrf    dividir
    
    movf    dias+1, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfss   ZERO
    goto    $+14
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   0
    subwf   dividir, F
    btfss   ZERO
    goto    $+7
    clrf    dias+1
    clrf    dias
    movlw   2
    addwf   dias+1
    movlw   8
    addwf   dias
    clrf    dividir
    
    movf    dias+1, W
    movwf   dividir
    movlw   3
    subwf   dividir, F
    btfss   ZERO
    goto    $+7
    clrf    dias+1
    clrf    dias
    movlw   2
    addwf   dias+1
    movlw   8
    addwf   dias
    clrf    dividir
    return

MARZO:
    clrf    dividir_mes+1
    movlw   3
    movwf   dividir_mes
    
    call    DIAS_31
    return
ABRIL:
    clrf    dividir_mes+1
    movlw   4
    movwf   dividir_mes
    
    call    DIAS_30
    return
    
MAYO:
    clrf    dividir_mes+1
    movlw   5
    movwf   dividir_mes
    
    call    DIAS_31
    return
    
JUNIO:
    clrf    dividir_mes+1
    movlw   6
    movwf   dividir_mes
    
    call    DIAS_30
    return
    
JULIO:
    clrf    dividir_mes+1
    movlw   7
    movwf   dividir_mes
    
    call    DIAS_31
    return
    
AGOSTO:
    clrf    dividir_mes+1
    movlw   8
    movwf   dividir_mes
    
    call    DIAS_31
    return
    
SEPTIEMBRE:
    clrf    dividir_mes+1
    movlw   9
    movwf   dividir_mes
    
    call    DIAS_30
    return
    
OCTUBRE:
    clrf    dividir_mes
    movlw   1
    movwf   dividir_mes+1
    
    call    DIAS_31
    return
    
NOVIEMBRE:
    movlw   1
    movwf   dividir_mes
    movlw   1
    movwf   dividir_mes+1
    
    call    DIAS_30
    return

DICIEMBRE:
    movlw   2
    movwf   dividir_mes
    movlw   1
    movwf   dividir_mes+1
    
    call    DIAS_31
    return
    
RESET_MES:  
    clrf    mes
    clrf    Editar_Aceptar
    
    movlw   1
    movwf   Editar_Aceptar
    return

;*******************************************************************************
;----------------TIMER----------------------------------------------------------
;*******************************************************************************

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

    
;-------------------------------------------------------------------------------    
//ORG 600h
MESES:
    clrf    PCLATH		; Limpiamos registro PCLATH
    bsf	    PCLATH, 2		; Posicionamos el PC en dirección 02xxh
    andlw   0x0F		; no saltar más del tamaño de la tabla
    addwf   PCL
    goto    ENERO
    goto    FEBRERO
    goto    MARZO
    goto    ABRIL
    goto    MAYO
    goto    JUNIO
    goto    JULIO
    goto    AGOSTO
    goto    SEPTIEMBRE
    goto    OCTUBRE
    goto    NOVIEMBRE
    goto    DICIEMBRE
    goto    RESET_MES

