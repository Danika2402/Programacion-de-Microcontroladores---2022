#include <xc.inc>
#include "macros.inc"
    
; Obtenemos variables/subrutinas globales a utilizar en este archivo
;   *Para esto puede usarse EXTRN en lugar de global
GLOBAL BMODO, BACCION
GLOBAL MOSTRAR_VALOR

; Definimos etiquetas de las subrutinas como globales para que sean accesibles
; desde otros archivos
GLOBAL INT_TMR0, INT_PORTB
  
PSECT code  ; Indicamos que esta sección de programa contiene código
INT_TMR0:
    RESET_TMR0 61		; Reiniciamos TMR0 para 50ms
    CALL    MOSTRAR_VALOR	; Mostramos valor en hexadecimal en los displays
    RETURN
    
INT_PORTB:
    BTFSC   PORTD, 2		; Verificamos en que estado estamos (S1 o S2)
    GOTO    ESTADO_1
    
    ESTADO_0:
	BTFSS   PORTB, BMODO	; Si se presionó botón de cambio de modo
	BSF	PORTD, 2	; Pasar a S1
	BTFSS   PORTB, BACCION	; Si se presionó botón de acción
	INCF    PORTA		; Incrementar PORTA
	BCF	RBIF		; Limpiamos bandera de interrupción
    RETURN

    ESTADO_1:
	BTFSS   PORTB, BMODO	; Si se presionó botón de cambio de modo
	BCF	PORTD, 2	; Pasar a S0
	BTFSS   PORTB, BACCION	; Si se presionó botón de acción
	DECF    PORTA		; Decrementar PORTA
	BCF	RBIF		; Limpiamos bandera de interrupción
    RETURN

