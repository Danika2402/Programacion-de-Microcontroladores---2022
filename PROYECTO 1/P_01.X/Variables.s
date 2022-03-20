#include <xc.inc>
    
GLOBAL	W_TEMP,STATUS_TEMP	
GLOBAL	banderas, nibbles, display
GLOBAL	segundos, minutos, horas
GLOBAL	mes, dias, dividir_mes
GLOBAL	segundos_timer, minutos_timer,alarma,parar_timer,apagar_led
GLOBAL	cont1, cont2, modo
GLOBAL	Editar_Aceptar, dividir
    
PSECT udata_shr
    W_TEMP:	DS 1
    STATUS_TEMP:DS 1	
    
PSECT udata_bank0
    cont1:	DS 1
    cont2:	DS 1
    modo:	DS 1
    
    //variablea RELOJ DIGITAL
    segundos:	DS 1
    minutos:	DS 2
    horas:	DS 2
    
    //variables FECHAS
    mes:	    DS 1
    dias:	    DS 2
    dividir_mes:    DS 2
    
    //variables TIMER
    segundos_timer:	DS 2
    minutos_timer:	DS 2
    alarma:		DS 1
    parar_timer:	DS 1
    apagar_led:		DS 1
    
    //Variables generales
    Editar_Aceptar: DS 1
    dividir:	    DS 1
    
    banderas:	DS 1	; Indica que display hay que encender
    nibbles:	DS 4	; Contiene los nibbles alto y bajo de "valor"
    display:	DS 4	; Representación de cada nibble en el display
   


