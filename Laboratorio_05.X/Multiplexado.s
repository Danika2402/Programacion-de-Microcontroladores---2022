;Archivo:	Multiplexado.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		20/02/2022
;Ultima modificacion:	25/02/2022
    
        
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
    banksel TMR0	//10ms
    movlw   217
    movwf   TMR0
    bcf	    T0IF
    ENDM

;------------------------------------------------------------------------------
PSECT udata_bank0  
    valor:	DS 1	; Contiene valor a mostrar en los displays 
    banderas:	DS 1	; Indica que display hay que encender
    nibbles:	DS 2	; Contiene los nibbles alto y bajo de "valor"
    display:	DS 5	; Representación de cada nibble en el display
    
    dividir:	DS 1
    unidad:	DS 1
    decena:	DS 1 
    centena:	DS 1
    
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
    btfss   PORTB, 0	    //incrementamos B con RB0, decrementamos con RB1
    incf    PORTA
    btfss   PORTB, 1
    decf    PORTA
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
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    
    movf    PORTA, W		    //movemos PORTA  a W
    movwf   valor		    //movemos W a "valor"
    call    NIBBLE_7
    call    DISPLAY_SET
    
    movf    PORTA, W		    //movemos PORTA a W y a "dividir"
    movwf   dividir
    
    call    _100
    movf   centena, W
    
    call    _10
    movf   decena, W
    
    call    _1
    movf   unidad, W
    
    goto    loop

config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD	    
    clrf    TRISA
    clrf    TRISC
    
    bsf	    TRISB, 0	    //RB0 y RB1 como entrada
    bsf	    TRISB, 1
    bcf	    TRISD, 0
    bcf	    TRISD, 1	    //bits 01234 de PORTD como entrada
    bcf	    TRISD, 2
    bcf	    TRISD, 3
    bcf	    TRISD, 4 

    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0 y RB1
    bsf	    WPUB, 1
    
    banksel PORTA	    
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    banderas
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
    
NIBBLE_7:
    movlw   0x0f	    //guardamos los bits menos significativos en nibbles
    andwf   valor, W
    movwf   nibbles
    
    movlw   0xf0
    andwf   valor, W	    //guardamos los bits mas significativos en nibbles
    movwf   nibbles+1	    //pero en diferente bit
    swapf   nibbles+1, F
    return
    
DISPLAY_SET:
    movf    nibbles, W
    call    tabla	    //pasamos la variable a W y llamamos tabla,
    movwf   display	    //para que se muestre en el display 7, con display
    
    movf    nibbles+1, W
    call    tabla
    movwf   display+1
    
    movf    centena, W
    call    tabla
    movwf   display+2
    
    movf    decena, W
    call    tabla
    movwf   display+3
    
    movf    unidad, W
    call    tabla
    movwf   display+4
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
    
    btfss   banderas, 4
    goto    display_4
    
    display_0:
	movf	display, W	//aqui movemos lo que esta en display a W
	movwf	PORTC		//y eso lo movemos al PORTC donde esta el display
	bsf	PORTD, 1	//y encendemos el bit de PORTD
	bsf	banderas, 1	//donde el display esta conectado
	return

    display_1:
	movf	display+1, W
	movwf	PORTC
	bsf	PORTD, 0 
	bsf	banderas, 0
	return

    display_2:
	bsf	banderas, 2
	movf	display+2, W
	movwf	PORTC
	bsf	PORTD, 2
	return
    
    display_3:
	bsf	banderas, 3
	movf	display+3, W
	movwf	PORTC
	bsf	PORTD, 3
	return
    
    display_4:
	clrf	banderas
	movf	display+4, W
	movwf	PORTC
	bsf	PORTD, 4
	return
	
	
_100:
    clrf    centena	    //si resta + -> c = 1
    movlw   100		    //si resta 0 -> c = 1
    subwf   dividir, F	    //si resta - -> c = 0
    btfsc   CARRY	    // si carry es 0 entonces 100 es mayor que PORTA
    incf    centena	    //si carry es 1, 100 es menor/igual que PORTA
    btfsc   CARRY
    goto    $-5
    movlw   100
    addwf   dividir, F
    return
    
_10:
    clrf    decena
    movlw   10
    subwf   dividir, F
    btfsc   CARRY
    incf    decena
    btfsc   CARRY
    goto    $-5
    movlw   10
    addwf   dividir, F
    return
     
_1:
    clrf    unidad
    movlw   1
    subwf   dividir, F
    btfsc   CARRY 
    incf    unidad
    btfsc   CARRY
    goto    $-5
    movlw   1
    addwf   dividir, F
    return
    
END