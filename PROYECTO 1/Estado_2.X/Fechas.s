;Archivo:	Fechas.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		09/03/2022
;Ultima modificacion:	09/03/2022
    
        
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
    
;------------------------------------------------------------------------------
PSECT udata_bank0  
    meses:	DS 2
    dias:	DS 2
    dividir:	DS 1
    
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
    /*
    btfsc   TMR1IF	    //si la bandera esta apagado, skip la siguiente linea
    call    T1_int*/

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
    
IO_int:
    banksel PORTB
    btfss   PORTB, 2
    incf    Editar_Aceptar
    call    EDITAR_FECHA
    bcf	    RBIF
    return
    
PSECT code, delta=2, abs
 ORG 100h
 
tabla:
    clrf    PCLATH	;ANODO COMUN
    bsf	    PCLATH, 0	;PCLATH = 01
    andlw   0x0f	;me aseguro q solo pasen 4 bits
    addwf   PCL		;PC = PCL + PCLATH + w
    retlw   00000011B	;0
    retlw   10011111B	;1
    retlw   00100101B	;2
    retlw   00001101B	;3
    retlw   10011001B	;4
    retlw   01001001B	;5
    retlw   01000001B	;6
    retlw   00011111B	;7
    retlw   00000001B	;8
    retlw   00001001B	;9
    retlw   00010001B	;A
    retlw   11000001B	;B
    retlw   01100011B	;C
    retlw   10000101B	;D
    retlw   01100001B	;E
    retlw   01110001B	;F

;---------------CONFIGURACION--------------------------------------------------

main:
    call    config_ports
    call    reloj
    call    config_tmr0
    //call    config_tmr1
    call    config_int
    banksel PORTD
    
;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    call    DISPLAY_SET
    call    NIBBLE_FECHA
    call    Fecha_digitos
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
    //bsf	    TRISB, 3	    //INICIAR/ACEPTAR
    //bsf	    TRISB, 4	    //MODO
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0 y RB1
    bsf	    WPUB, 1
    bsf	    WPUB, 2
    //bsf	    WPUB, 3
    //bsf	    WPUB, 4
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    clrf    Editar_Aceptar
    clrf    dias+1
    clrf    dias+1
    clrf    dias
    clrf    meses
    movlw   0x01
    addwf   dias
    movlw   0x01
    addwf   meses
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

config_int:
    //banksel PIE1
    //bsf	    TMR1IE	    //interrupcion TMR1
    //bsf	    TMR2IE	    //interrupcion TMR2
    
    banksel TRISB	    //configuracion para interrupcion en B
    bsf	    IOCB, 0	    //DISPLAY UP/INCREMENTAR
    bsf	    IOCB, 1	    //DISPLAY DOWN/DECREMENTAR
    bsf	    IOCB, 2	    //EDITAR/ACEPTAR
    //bsf	    IOCB, 3	    //INICIAR/PARAR
    //bsf	    IOCB, 4	    //MODO
    
    banksel PORTB	    //mismatch
    movf    PORTB, W
    
    banksel INTCON
    //bsf	    PEIE
    bsf	    GIE		    //Habilitar interrupciones
    bsf	    RBIE	    //habilitar interrupcion en PORTB
    bcf	    RBIF	    //limpiar bandera
    bcf	    T0IF	    //limpiar bandera tmr0
    bsf	    T0IE	    //habilitar interrupcion en TMR0
    //bcf	    TMR1IF	    //bandera en TMR1
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
	
NIBBLE_FECHA:
    movf    dias, W
    movwf   nibbles
    
    movf    dias+1, W
    movwf   nibbles+1
    
    movf    meses, W
    movwf   nibbles+2
    
    movf    meses+1, W
    movwf   nibbles+3
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
    bcf	    PORTE,2
    
    return
    
MODIFICAR_MESES:
    banksel PORTB
    bcf	    PORTE,0
    bsf	    PORTE,1
    bcf	    PORTE,2
    
    btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
    incf    meses
    btfss   PORTB, 1
    decf    meses
    bcf	    RBIF
    
    return
    
MODIFICAR_DIAS: 
    banksel PORTB
    bsf	    PORTE,0
    bcf	    PORTE,1
    bcf	    PORTE,2
    
    btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
    incf    dias
    btfss   PORTB, 1
    decf    dias
    bcf	    RBIF
    return
    
Fecha_digitos:
    
    movf    meses,W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	//si z=0 skip
    goto    $+3
    clrf    meses
    incf    meses+1
    
    movf    dias, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO
    goto    $+3
    clrf    dias
    incf    dias+1
    
    return    
    
Fecha_dias:
    
    return
    
ORG 200h
MESES:
    clrf    PCLATH		; Limpiamos registro PCLATH
    bsf	    PCLATH, 1		; Posicionamos el PC en dirección 02xxh
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
    clrf    meses