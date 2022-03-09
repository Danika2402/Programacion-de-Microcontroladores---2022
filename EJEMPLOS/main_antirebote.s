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
; -------------- VECTOR RESET ---------------
ORG 00h		; posición 0000h - Vector de reset
resVect:
    GOTO main
    
PSECT code, delta=2, abs
ORG 100
; ------------- CONFIGURACIONES --------------
main:
    BSF	    STATUS, 5	    ; banco 01
    BSF	    STATUS, 6	    ; banco 11
    CLRF    ANSEL	    ; todos los pines como digitales
    CLRF    ANSELH
    
    BCF	    STATUS, 6	    ; banco 01
    BSF	    TRISA, 0	    ; RA0 como entrada
    CLRF    TRISB	    ; PORTB como salida
    BCF	    STATUS, 5	    ; banco 00
    CLRF    PORTB	    ; apagar PORTB
    
CHECKBOTON:
    BTFSC   PORTA, 0	    ; ver si botón está presionado
    GOTO CHECKBOTON
    
ANTIREBOTE:
    BTFSS   PORTA, 0	    ; ver si el botón está presionado
    GOTO ANTIREBOTE
    
    INCF PORTB, F	    ; incrementamos PORTB y guardamos en PORTB
    GOTO CHECKBOTON
    
END
