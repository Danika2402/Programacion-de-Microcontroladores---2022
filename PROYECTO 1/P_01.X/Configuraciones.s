#include <xc.inc>
#include "Macros.inc"

GLOBAL	config_ports,reloj,config_tmr0,config_tmr1,config_tmr2,config_int
GLOBAL	segundos, minutos, horas
GLOBAL	mes, dias, dividir_mes
GLOBAL	segundos_timer, minutos_timer,alarma,parar_timer,apagar_led
GLOBAL	Editar_Aceptar, dividir
GLOBAL	cont1, cont2, modo
    
PSECT code
 
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD	    
    clrf    TRISC
    clrf    TRISA
    clrf    TRISE
    
    bcf	    TRISD, 0
    bcf	    TRISD, 1	    //bits de PORTD como salida
    bcf	    TRISD, 2
    bcf	    TRISD, 3
    
    bsf	    TRISB, 0	    //DISPLAY_UP
    bsf	    TRISB, 1	    //DISPLAY_DOWN
    bsf	    TRISB, 2	    //EDITAR/ACEPTAR
    bsf	    TRISB, 3	    //INICIAR/ACEPTAR
    bsf	    TRISB, 4	    //MODO
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0 y RB1
    bsf	    WPUB, 1
    bsf	    WPUB, 2
    bsf	    WPUB, 3
    bsf	    WPUB, 4
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    
    clrf    Editar_Aceptar
    clrf    dividir
    clrf    cont1
    clrf    cont2
    clrf    modo
    
    clrf    segundos
    clrf    minutos
    clrf    horas
    
    clrf    mes
    clrf    dias
    clrf    dividir_mes
    
    clrf    segundos_timer 
    clrf    minutos_timer
    clrf    alarma
    clrf    parar_timer
    clrf    apagar_led
    return
    
reloj:
    banksel OSCCON
    bsf	    IRCF2   //1
    bcf	    IRCF1   //0 = 1MHz
    bcf	    IRCF0   //0
    bsf	    SCS	   
    return
    
config_tmr0:
    banksel OPTION_REG
    bcf	    T0CS
    bcf	    PSA
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0		    //prescaler -> 111= 1:256
    
    RESET_TMR0
    return
    
config_tmr1:
    banksel T1CON
    bcf	    TMR1GE	//tmr1 siempre cuenta
    bsf	    T1CKPS1	//prescaler
    bsf	    T1CKPS0	//1:8
    
    bcf	    T1OSCEN	//LP deshabilitado
    bcf	    TMR1CS	//reloj interno 
    bsf	    TMR1ON
    
    RESET_TMR1
    return
    
config_tmr2:
    banksel PR2
    movlw   244		    //250ms
    movwf   PR2
    
    banksel T2CON
    bsf	    T2CKPS1	    //prescaler 1:16
    bsf	    T2CKPS0
    
    bsf	    TOUTPS3	    //postscaler 1:16
    bsf	    TOUTPS2
    bsf	    TOUTPS1
    bsf	    TOUTPS0
    
    bsf	    TMR2ON  
    return
    
config_int:
    banksel PIE1
   // bsf	    TMR1IE	    //interrupcion TMR1
   // bsf	    TMR2IE	    //interrupcion TMR2
    
    banksel TRISB	    //configuracion para interrupcion en B
    bsf	    IOCB, 0	    //DISPLAY UP/INCREMENTAR
    bsf	    IOCB, 1	    //DISPLAY DOWN/DECREMENTAR
    bsf	    IOCB, 2	    //EDITAR/ACEPTAR
    bsf	    IOCB, 3	    //INICIAR/PARAR
    bsf	    IOCB, 4	    //MODO
    
    banksel PORTB	    //mismatch
    movf    PORTB, W
    
    banksel INTCON
    bsf	    PEIE
    bsf	    GIE		    //Habilitar interrupciones
    bsf	    RBIE	    //habilitar interrupcion en PORTB
    bcf	    RBIF	    //limpiar bandera
    bcf	    T0IF	    //limpiar bandera tmr0
    bsf	    T0IE	    //habilitar interrupcion en TMR0
    //bcf	    TMR1IF	    //bandera en TMR1
    //bcf	    TMR2IF
    return


