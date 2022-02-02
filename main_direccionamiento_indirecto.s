; ----------------------------------------------------
; Universidad del Valle de Guatemala
; Programación de Microcontroladores
; Christopher Chiroy
; 31 Enero 2022
; Direccionamiento indirecto - Escritura de GPR desde 0x20 hasta 0x2F
; ----------------------------------------------------
    
PROCESSOR 16F887
    
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
    
PSECT resVect, class=CODE, abs, delta=2
ORG 00h	    ; posición 0000h para el reset
;------------ VECTOR RESET --------------
resetVec:
    PAGESEL MAIN	; Cambio de banco
    GOTO    MAIN
    
PSECT code, delta=2, abs
ORG 100h    ; posición 100h para el codigo
;------------- CONFIGURACION ------------
MAIN:
    CALL    CONFIGS
    
LOOP:
    MOVLW   0x20	; Dirección del rimer GPR del banco 0
    MOVWF   FSR		; Guardamos la dirección para usar dir. indirecto
    
WRITE:
    MOVF    PORTD, W	; Guardamos el valor del PORTB en W
    MOVWF   INDF	; Guardamos el valor de W en el registro al que apunta
			;   la dirección guardada en el FSR
    INCF    FSR		; Cambiamos la dirección al siguiente GPR del banco 0
    BTFSS   FSR, 4	; Guardar datos de 0x20 hasta llegar a 0x2F
    GOTO    WRITE	; Repetir
    
    GOTO    LOOP

;----------- SUBRUTINAS -------------
CONFIGS:
    BANKSEL PORTD	; Cambio de banco
    CLRF    PORTD	; Limpiamos PORTD
    BANKSEL TRISD	; Cambio de banco
    MOVLW   0xFF	
    MOVWF   TRISD	; Configuramos PORTD como entradas
    BANKSEL PORTD	; Cambio de banco
    RETURN

END


