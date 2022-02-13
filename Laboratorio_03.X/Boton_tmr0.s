;Archivo:	Boton y tmr0.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:		
;Hardware:	
;		
;
;Creado:		06/02/2022
;Ultima modificacion:	12/02/2022
    
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
    cont:	DS 1 
    //cont1:	DS 1
    cont_small: DS 1
    
PSECT resVect, class=CODE,abs, delta=2
;-----------------Vector Reset-----------------
ORG 00h
resetVec:
    PAGESEL main
    goto main
	
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
    banksel PORTC
    
;-------------LOOP-------------------------------------------------------------
loop:
    btfsc   T0IF
    call    loop_tmr0	    //contador TMR0 a 100ms

    btfsc   PORTB, 0	    //incrementa display 7
    call    inc_display
    
    btfsc   PORTB, 1	    //decrementa display 7
    call    dec_display
    
    movf    cont, W	    //igualdad entre tmr0 y display 7
    subwf   PORTC, W
    btfsc   STATUS, 2
    call    Resta
    bcf	    PORTB, 3
    
    goto    loop
;-----------sub rutinas-------------------------------------------------------- 

loop_tmr0:
    call    reinicio_tmr0	//contador tmr0
    incf    PORTC
    movlw   0b00001111
    andwf   PORTC
    /*
    decfsz  cont1
    subwf   cont1	//cont1 - W 
    btfss   STATUS, 2	//bandera zero
    incf    PORTD
    //call    loop2*/
    return
/*
loop2:
    incf    PORTD
    movlw   0b00001111
    andwf   PORTD
    return*/
    
inc_display:
    btfsc   PORTB, 0	    
    goto    $-1
    
    incf    cont	    //se incrementa la variable, 
    movlw   0b00001111	    //cont se multiplica con W para usar solo 4 bits
    andwf   cont	    //luego cont se mueve a W
    movf    cont,W	    //y llamamos a tabla
    call    tabla	    //y eso se mueve a PORTA 
    movwf   PORTA
    return
    
dec_display:
    btfsc   PORTB, 1
    goto    $-1
   
    decfsz  cont
    movlw   0b00001111	    
    andwf   cont
    movf    cont,W
    call    tabla
    movwf   PORTA	    
    return
    
Resta:
    call    reinicio_tmr0	//se enciende PORTB3
    bsf	    PORTB, 3		
    movlw   800			//pequeño delay
    movwf   cont_small
    decfsz  cont_small, 1
    goto    $-1
    return
    
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISC	//puertos A,C,D como salida
    clrf    TRISC
    clrf    TRISA
    clrf    TRISB
    bsf	    TRISB,0	//puerto B bits 0 y 1 como entrada
    bsf	    TRISB,1
    
    banksel PORTC
    clrf    PORTC
    clrf    PORTA
    //clrf    PORTD
    clrf    PORTB
    clrf    cont
    //movlw   0x0A
    //movwf   cont1
    
    return
    
config_tmr0:
    banksel OSCCON  //OSCILOSCOPIO
    bsf	    IRCF2   //1
    bcf	    IRCF1   //0 = 1MHz
    bcf	    IRCF0   //0
    bsf	    SCS	    ;reloj interno activo
    
    banksel OPTION_REG
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0	    //prescaler -> 111= 1:256
    bcf	    T0CS
    
    call    reinicio_tmr0
    return
    
reinicio_tmr0:
    banksel TMR0    //100ms
    movlw   158
    movwf   TMR0
    bcf	    T0IF
    btfsc   STATUS,2
    clrf    PORTC
    return
    
    


