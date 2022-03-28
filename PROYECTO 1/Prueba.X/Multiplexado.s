#include <xc.inc>
GLOBAL	tabla
GLOBAL	banderas, nibbles, display
GLOBAL	minutos, horas
GLOBAL	dias, dividir_mes
GLOBAL	segundos_timer, minutos_timer
    
GLOBAL	MOSTRAR_VALOR, DISPLAY_SET
GLOBAL	NIBBLE_RELOJ, NIBBLE_FECHA, NIBBLE_TIMER
    
PSECT code   
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