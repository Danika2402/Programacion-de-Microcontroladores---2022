;Archivo:	Sumador.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	2 contadores 4 bits que se suman	
;Hardware:	contador en PORTC y PORTB, resultado de suma en PORTD
;		botones en PORTA
;
;Creado:	30/01/2022
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
    
PSECT udata_bank0
    suma: DS 1 
    
    
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
    bsf	    STATUS,5	;banco 01
    bsf	    STATUS, 6	;banco 11
    clrf    ANSEL
    clrf    ANSELH
    
    bcf	    STATUS,6	;BANCO 01   
    bsf	    TRISA, 0	//contador B, incrementa
    bsf	    TRISA, 1	//contador B, decrementa
    bsf	    TRISA, 2	//contador C, incrementa
    bsf	    TRISA, 3	//contador C, decrementa
    bsf	    TRISA, 4	//Sumador
    clrf    TRISB	//puertos B,C y D como salida 
    clrf    TRISC
    clrf    TRISD
    
    bsf	    IRCF2   //OSCILOSCOPIO
    bcf	    IRCF1   //100 = 1MHz
    bcf	    IRCF0
    bsf	    SCS	    ;reloj interno activo
    
    bcf	    STATUS, 5
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD

;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:	    
    btfss   PORTA, 0
    call    ANTIREBOTE1	    //incremento de PORTB
    
    btfss   PORTA, 1
    call    ANTIREBOTE2	    //decremento de PORTB
    
    btfss   PORTA, 2
    call    ANTIREBOTE3	    //incremento de PORTC
    
    btfss   PORTA, 3
    call    ANTIREBOTE4	    //decremento de PORTC
    
    btfss   PORTA, 4
    call    ANTIREBOTE5	    //sumador en puerto D
    
    goto loop
    
;-----------sub rutinas--------------------------------------------------------    

//*****Contador puerto B
ANTIREBOTE1:
    btfss   PORTA,0	    //si esta apagado el bit skip siguiente linea
    goto    $-1		    //se regresa 1 linea
    incf    PORTB	    //incremente puerto
    movlw   0b00001111	    //aqui hacemos que solo los primeros
    andwf   PORTB	    //4 bits utilizaremos
    return		    //para que sea un contador de 4 bits
    
ANTIREBOTE2:
    btfss   PORTA,1
    goto    $-1
    decfsz  PORTB
    movlw   0b00001111
    andwf   PORTB
    return

    
//*******Contador puerto C
ANTIREBOTE3:
    btfss   PORTA,2 
    goto    $-1		    
    incf    PORTC
    movlw   0b00001111
    andwf   PORTC
    return
    
ANTIREBOTE4:
    btfss   PORTA,3
    goto    $-1
    decfsz  PORTC
    movlw   0b00001111
    andwf   PORTC
    return

ANTIREBOTE5:
    btfss   PORTA, 4	    
    goto    $-1		    
    
    movf    PORTB, W	   //mover de PORTB a W
    movwf   suma	    //mover el valor de W a la variable "suma"
    movf    PORTC, W	    //W se limpia y lo usamos para mover el PORTC
    addwf   suma,W	    //sumamos W y "suma" y se guarda en W
    movwf   PORTD	    //el producto lo movemos a PORTD
    
    movlw   0b00011111	    //modificamos para solo 4 bits y overflow
    andwf   PORTD
    return    
END