#include <xc.inc>
#include "macros.inc"
    
; Obtenemos variables globales a utilizar en este archivo
;   *Para esto puede usarse EXTRN en lugar de global
GLOBAL BMODO, BACCION
GLOBAL banderas
    
; Definimos etiquetas de las subrutinas como globales para que sean accesibles
; desde otros archivos
GLOBAL CONFIG_IO, CONFIG_RELOJ, CONFIG_TMR0, CONFIG_INT

PSECT code  ; Indicamos que esta sección de programa contiene código
CONFIG_RELOJ:
    BANKSEL OSCCON		; cambiamos a banco 1
    BSF	    OSCCON, 0		; SCS -> 1, Usamos reloj interno
    BSF	    OSCCON, 6
    BSF	    OSCCON, 5
    BCF	    OSCCON, 4		; IRCF<2:0> -> 110 4MHz
    RETURN
    
CONFIG_TMR0:
    BANKSEL OPTION_REG		; cambiamos de banco
    BCF	    T0CS		; TMR0 como temporizador
    BCF	    PSA			; prescaler a TMR0
    BSF	    PS2
    BSF	    PS1
    BSF	    PS0			; PS<2:0> -> 111 prescaler 1 : 256
    RESET_TMR0 61		; Reiniciamos TMR0 para 50ms
    RETURN 
    
CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH		; I/O digitales
    BANKSEL TRISC
    CLRF    TRISC		; PORTC como salida
    BCF	    TRISD, 0		; RD0 como salida / display nibble alto
    BCF	    TRISD, 1		; RD1 como salida / display nibble bajo
    BCF	    TRISD, 2		; RD2 como salida / indicador de estado
    BSF	    TRISB, BMODO	; RB0 como entrada / Botón modo
    BSF	    TRISB, BACCION	; RB1 como entrada / Botón acción
    CLRF    TRISA		; RBA como salida
    BANKSEL PORTC
    CLRF    PORTC		; Apagamos PORTC
    BCF	    PORTD, 0		; Apagamos RD0
    BCF	    PORTD, 1		; Apagamos RD1
    BCF	    PORTD, 2		; Apagamos RD2
    
    CLRF    PORTA		; Apagamos PORTA
    CLRF    banderas		; Limpiamos GPR
    RETURN
    
CONFIG_INT:
    BANKSEL IOCB		
    BSF	    IOCB0		; Habilitamos int. por cambio de estado en RB0
    BSF	    IOCB1		; Habilitamos int. por cambio de estado en RB1
    BANKSEL PORTB		
    MOVF    PORTB, W
    
    BANKSEL INTCON
    BSF	    GIE			; Habilitamos interrupciones
    BSF	    T0IE		; Habilitamos interrupcion TMR0
    BCF	    T0IF		; Limpiamos bandera de int. de TMR0
    BSF	    RBIE		; Habiltamos interrupciones del PORTB
    BCF	    RBIF		; Limpiamos bandera de int. de PORTB
    RETURN



