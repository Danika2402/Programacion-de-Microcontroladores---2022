#include <xc.inc>
#include "Macros.inc"

GLOBAL	segundos, minutos, horas
GLOBAL	mes, dias, dividir_mes
GLOBAL	segundos_timer, minutos_timer,alarma,parar_timer,apagar_led
GLOBAL	Editar_Aceptar, dividir
GLOBAL	cont1, cont2, modo
GLOBAL	MOSTRAR_VALOR

GLOBAL	TO_int, T2_int 
GLOBAL	T1_RELOJ, IO_RELOJ
GLOBAL	IO_FECHAS
GLOBAL	T1_TIMER, IO_TIMER
    
PSECT code
 
TO_int:
    RESET_TMR0
    call    MOSTRAR_VALOR
    return

T2_int:
    bcf	    TMR2IF
    incf    cont1
    movf    cont1, W
    sublw   2		//250ms * 2 = 500ms
    btfsc   ZERO
    goto    $+3
    bsf	    PORTC, 0
    clrf    cont1
    
    incf    cont2
    movf    cont2, W
    sublw   2		//250ms * 2 = 500ms
    btfsc   ZERO
    goto    $+3
    bcf	    PORTC, 0
    clrf    cont2
    
    return
    
;-----Interrupciones Reloj digital--------------------------------------
T1_RELOJ:
    RESET_TMR1
    incf    segundos
    return
    
IO_RELOJ:
    banksel PORTB
    btfss   PORTB, 2
    incf    Editar_Aceptar
    bcf	    RBIF
    call    EDITAR_RELOJ
    return
   
;-------Interrupciones Fechas-----------------------------------------
    
IO_FECHAS:
    banksel PORTB
    btfss   PORTB, 2
    incf    Editar_Aceptar
    call    EDITAR_FECHA
    bcf	    RBIF
    return

;------Interrupciones Timer-------------------------------------------
T1_TIMER:
    RESET_TMR1
    movf    alarma, W
    sublw   1
    btfsc   ZERO	    //si Z=0 skip
    decf    segundos_timer
    
    movf    parar_timer, W
    sublw   1
    btfsc   ZERO
    call    LED_1MINUTO
    return
    
IO_TIMER:
    banksel PORTB
    btfss   PORTB, 2
    incf    Editar_Aceptar
    
    btfss   PORTB, 3
    incf    alarma
    
    bcf	    RBIF
    call    EDITAR_TIMER
    
    return
    
///////////////////////////////////////////////////////////////////////    
;-------EDITAR ESTADOS------------------------------------------------
///////////////////////////////////////////////////////////////////////
    
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

LED_1MINUTO:
    bsf	PORTE,2
    incf    apagar_led
    return