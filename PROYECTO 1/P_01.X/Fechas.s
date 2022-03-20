#include <xc.inc>
    
GLOBAL	mes, dias, dividir_mes
GLOBAL	Editar_Aceptar, dividir
    
GLOBAL	Fecha_digitos, UNDERFLOW_FECHA, MESES
    
PSECT code
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
    goto    $+12
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   1
    subwf   dividir, F
    btfss   CARRY    
    goto    $+5
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
    goto    $+12
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfss   CARRY    
    goto    $+5
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
    goto    $+12
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   9
    subwf   dividir, F
    btfss   CARRY   
    goto    $+5
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
    
ORG 400h
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

