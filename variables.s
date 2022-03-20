#include <xc.inc>

; Definimos variables como globales para que sean accesibles desde otros archivos
GLOBAL BMODO, BACCION
GLOBAL W_TEMP, STATUS_TEMP   
GLOBAL valor, banderas, nibbles, display
    
BMODO EQU 0
BACCION EQU 1
  
; ------- VARIABLES EN MEMORIA --------
PSECT udata_shr		    ; Memoria compartida
    W_TEMP:		DS 1
    STATUS_TEMP:	DS 1
    
PSECT udata_bank0
    valor:		DS 1	; Contiene valor a mostrar en los displays de 7-seg
    banderas:		DS 1	; Indica que display hay que encender
    nibbles:		DS 2	; Contiene los nibbles alto y bajo de valor
    display:		DS 2	; Representación de cada nibble en el display de 7-seg
    