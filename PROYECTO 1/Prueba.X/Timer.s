#include <xc.inc>
    
GLOBAL	segundos_timer, minutos_timer,alarma,parar_timer,apagar_led
GLOBAL	Editar_Aceptar, dividir
GLOBAL	nibbles
    
GLOBAL	TIMER_DIGITOS, UNDERFLOW_TIMER, INICIAR_ALARMA
    
PSECT code
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



