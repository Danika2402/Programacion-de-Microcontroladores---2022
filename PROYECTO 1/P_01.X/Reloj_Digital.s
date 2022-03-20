#include <xc.inc>

GLOBAL	segundos, minutos, horas
GLOBAL	Editar_Aceptar, dividir
GLOBAL	nibbles
    
GLOBAL	Reloj_Digitos, UN_DIA, UNDERFLOW_RELOJ
   
PSECT code
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
    