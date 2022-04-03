;Archivo:	MAIN.s
;Dispositivo:	PIC16F887
;Autor:		Danika Andrino
;Compilador:	pic-as (2.30), MPLABX V6.00
;
;Programa:	
;Hardware:	
;    
;Creado:		05/03/2022
;Ultima modificacion:	21/03/2022
        
PROCESSOR 16F887
#include <xc.inc>
    
CONFIG FOSC  =   INTRC_NOCLKOUT	    //Bits de configuracion
CONFIG WDTE  =   OFF
CONFIG PWRTE =   OFF
CONFIG MCLRE =   OFF
CONFIG CP    =   OFF
CONFIG CPD   =   OFF
    
CONFIG BOREN =   OFF
CONFIG IESO  =   OFF
CONFIG FCMEN =   OFF
CONFIG LVP   =   OFF
    
CONFIG WRT   =   OFF
CONFIG BOR4V =   BOR40V

RESET_TMR0 MACRO 
    banksel TMR0	//2ms
    movlw   254
    movwf   TMR0
    bcf	    T0IF
ENDM
    
RESET_TMR1 MACRO	    //1s , 85EE = 34286	
    movlw   0x85	       
    movwf   TMR1H	    
    movlw   0xEE	      
    movwf   TMR1L	    
    bcf	    TMR1IF	     
ENDM

;------------------------------------------------------------------------------
PSECT udata_shr
    W_TEMP:	DS 1
    STATUS_TEMP:DS 1	
    
PSECT udata_bank0
    //variables RELOJ DIGITAL
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
    
    cont1:	DS 1
    modo:	DS 1
    
    //Variables para mutiplexado
    banderas:	DS 1	
    nibbles:	DS 4	
    display:	DS 4	
   
PSECT resVect, class=CODE,abs, delta=2
;-----------------Vector Reset--------------------------------------------------
ORG 00h
resetVec:
    PAGESEL main
    goto main
	
PSECT intVect, class=CODE, abs, delta=2
ORG 04h
;----------------Vector Interrupciones------------------------------------------    

PUSH:
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   STATUS_TEMP
    
ISR:			//si la bandera esta apagado, skip la siguiente linea
    btfsc   RBIF	    
    call    IO_int	//Interrupcion pull-up push button
    
    btfsc   TMR2IF	//Interrupcion TMR2
    call    T2_int
    
    btfsc   T0IF	//Interrupcion TMR0
    call    TO_int
    
    btfsc   TMR1IF	//Interupcion TMR1
    call    T1_int
 

POP:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

;----------------Subrutinas de Interrupcion ------------------------------------

TO_int:
    RESET_TMR0
    call    MOSTRAR_VALOR
    return
    
T1_int:			    
    RESET_TMR1			//incremente la variable "segundos"
    incf    segundos		//del Reloj digital
			    
    movf    alarma, W		//Si la variable "alarma" = 1, decremente 
    sublw   1			//la variable "segundos_timer" cada 1s
    btfsc   ZERO		//esto inicia el reloj timer
    decf    segundos_timer
    
    movf    parar_timer, W	//si la variable "parar_timer" = 1,	
    sublw   1			//ir a la subtutina LED_1MINUTO
    btfsc   ZERO		//sucede cuando el TIMER llega a 00:00
    call    LED_1MINUTO		//y enciende la buzer/led
    return
    
IO_int:
    banksel PORTB		//Interrupciones en el puerto B
    btfss   PORTB, 2		//si se preciona el boton "EDITAR" en RB2, con
    incf    Editar_Aceptar	//esto controlamos si incrementamos 
				//segundos, minutos, horas, meses o dias
				    
    btfss   PORTB, 3		//si se preciona el boton "ALARMA" en RB3, con
    incf    alarma		//esto iniciamos y paramos el TIMER y buzer/led
				
    btfsc   PORTB, 4		//si se preciona el boton "MODO" en RB4, con
    goto    $+3			//esto controlamos los estados Reloj, Fechas y 
    clrf    Editar_Aceptar	//Timer, limpiamos la variable "Editar_Aceptar"
    incf    modo		//para que no alla problemas al cambiar de estado
    
    bcf	    RBIF
    call    EDITAR		//Llamamos la subritna donde editamos las 
    return			//variables de segundos, minutos, horas, fechas
				//y meses, dependiendo del estado en que estamos
T2_int:
    bcf	    TMR2IF		//incrementamos "cont1" cada 250ms con TMR2
    incf    cont1
    return

////////////////////////////////////////////////////////////////////////////////
    
LED_1MINUTO:
    bsf	    PORTE,2		//encendemos el buzer/led que esta en PORTE 2
    incf    apagar_led		//eh incrementamos la variable, que mira si ya 
    return			//paso 1 minutos del buzer/led encendido
    
EDITAR:
    
    movf    modo, W		//Chequeamos la variable "modo", que indica que
    sublw   0			//estado estamos, Reloj, Fecha o Timer
    btfsc   ZERO		//dependiento de su valor entramos a otra 
    goto    EDITAR_RELOJ	//subrutina que edita sus variables
    
    movf    modo, W
    sublw   1
    btfsc   ZERO
    goto    EDITAR_FECHA
    
    movf    modo, W
    sublw   2
    btfsc   ZERO
    goto    EDITAR_TIMER
    return
    
////////////////////////////////////////////////////////////////////////////////    
    
EDITAR_RELOJ:
    //si resta + -> c=1, z=0	Si "modo" = 0, Entramos al primer estado
    //si resta 0 -> c=1, z=1	el RELOJ DIGITAL
    //si resta - -> c=0, z=0
    
    movf    Editar_Aceptar, W	//Chequeamos la variable "Editar_Aceptar"
    sublw   1			//dependiendo de su valor entramos a otra subrutina
    btfsc   ZERO		    
    goto    MODIFICAR_MINUTOS	    
    
    movf    Editar_Aceptar, W
    sublw   2		
    btfsc   ZERO		    
    goto    MODIFICAR_HORAS	    
    
    movf    Editar_Aceptar, W	//si la variable es 3, reinicia
    sublw   3		
    btfsc   ZERO		    
    clrf    Editar_Aceptar	    
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    return

    MODIFICAR_HORAS:		//si la variable es 1 entramos en modificar
	banksel PORTB		//las horas del Reloj digital
	bcf	PORTE,0		//Encendemos un led que indique esto
	bsf	PORTE,1		//y con RB0 y RB1 incrementamos y decrementamos
	bcf	PORTE,2		//las "horas"
	clrf    segundos

	btfss   PORTB, 0	    
	incf    horas
	btfss   PORTB, 1
	decf    horas
	bcf	RBIF
	return

    MODIFICAR_MINUTOS:		//si la variable es 2 entramos a modificar los
	banksel PORTB		//minutos del reloj digital
	bsf	PORTE,0		//con RB0 y RB1 incrementamos y decrementamos
	bcf	PORTE,1		//los "minutos"
	bcf	PORTE,2
	clrf    segundos

	btfss   PORTB, 0	   
	incf    minutos
	btfss   PORTB, 1
	decf    minutos
	bcf	RBIF
	return
    
EDITAR_FECHA:
    
    movf    Editar_Aceptar, W	//si modo=1, entramos en modificar la Fecha 
    sublw   1			//igual que en el anterior, dependiendo de
    btfsc   ZERO		//"Editar_Aceptar" modificamos los meses o dias
    goto    MODIFICAR_MESES	    
    
    movf    Editar_Aceptar, W
    sublw   2		
    btfsc   ZERO		    
    goto    MODIFICAR_DIAS	    
    
    movf    Editar_Aceptar, W
    sublw   3		
    btfsc   ZERO		    
    clrf    Editar_Aceptar	    
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    
    return
    
    MODIFICAR_MESES:		//aqui incrementamos o decrementamos los
	banksel PORTB		//"meses" que se usara luego para mostrar
	bcf	PORTE,0		//los meses en forma de numeros en el display
	bsf	PORTE,1
	bcf	PORTE,2

	btfss   PORTB, 0	    
	incf	mes
	btfss   PORTB, 1
	decf	mes
	bcf	RBIF

	return

    MODIFICAR_DIAS: 
	banksel PORTB		//aqui incrementamos o decrementamos los "dias"
	bsf	PORTE,0
	bcf	PORTE,1
	bcf	PORTE,2

	btfss   PORTB, 0	    
	incf    dias
	btfss   PORTB, 1
	decf    dias
	bcf	RBIF
	return

EDITAR_TIMER:
    
    movf    Editar_Aceptar, W	    //si modo=2 entramos a modificar el Timer
    sublw   1			    //donde modificamos los "minutos_timer" y
    btfsc   ZERO		    //los "segundos_timer" 
    goto    MODIFICAR_MINUTOS_TIMER	    
    
    movf    Editar_Aceptar, W
    sublw   2		
    btfsc   ZERO			    
    goto    MODIFICAR_SEGUNDOS_TIMER	    
    
    movf    Editar_Aceptar, W
    sublw   3		
    btfsc   ZERO			     
    clrf    Editar_Aceptar
    
    bcf	    PORTE,0
    bcf	    PORTE,1
    
    return
    
    MODIFICAR_MINUTOS_TIMER:
	banksel PORTB		    //incrmenentamos o decrementamos "minutos_timer"
	bcf	PORTE,0
	bsf	PORTE,1

	btfss   PORTB, 0	    
	incf	minutos_timer
	btfss   PORTB, 1
	decf	minutos_timer
	bcf	RBIF

	return

    MODIFICAR_SEGUNDOS_TIMER: 
	banksel PORTB
	bsf	PORTE,0
	bcf	PORTE,1
	
	btfss   PORTB, 0	    //incrmenentamos o decrementamos "segundos_timer"
	incf    segundos_timer
	btfss   PORTB, 1
	decf    segundos_timer
	bcf	RBIF
	return

	
////////////////////////////////////////////////////////////////////////////////
PSECT code, delta=2, abs
 ORG 100h
 tabla:			//utilizamos para mostrarlo en el display
    clrf    PCLATH
    bsf	    PCLATH, 0	;PCLATH = 01
    andlw   0x0f	;me aseguro q solo pasen 4 bits
    addwf   PCL		;PC = PCL + PCLATH + w
    retlw   11111100B	;0  
    retlw   01100000B	;1  
    retlw   11011010B	;2  
    retlw   11110010B	;3  
    retlw   01100110B	;4  
    retlw   10110110B	;5  
    retlw   10111110B	;6  
    retlw   11100000B	;7  
    retlw   11111110B	;8  
    retlw   11110110B	;9  
    retlw   11101110B	;A  
    retlw   00111110B	;B  
    retlw   10011100B	;C  
    retlw   01111010B	;D  
    retlw   10011110B	;E  
    retlw   10001110B	;F  

;---------------CONFIGURACION--------------------------------------------------
main:
    call    config_ports
    call    reloj
    call    config_tmr0
    call    config_tmr1
    call    config_tmr2
    call    config_int
    banksel PORTD
;-------------LOOP-------------------------------------------------------------
    //btfss revisa si el bit esta encendido, 
    //skip la siquiente linea, los botones estan conectados de forma pull-up
    //btfsc revisa si el bit esta apagado, skip la siguiente linea
loop:
    call    TMR2_LED	    //este se encarga de encender un led y apagarlo
			    //cada 500ms 
    call    DISPLAY_SET	    //Donde movemos "nibble" a "display"
    
    movf    modo, W	    //Chequeamos modo, que nos manda a un loop que nos
    movwf   dividir	    //ayuda en mostrar en los displays las variables
    movlw   0		    //de cada estado
    subwf   dividir, F	    //si modo =0 entra al ESTADO_1 que es el reloj digital
    btfsc   ZERO
    call    ESTADO_1
    clrf    dividir
    
    movf    modo, W
    movwf   dividir	    //si modo =1 entra a ESTADO_2 que es la Fecha
    movlw   1
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_2
    clrf    dividir
    
    movf    modo, W	    //si modo=2 entra a ESTADO_3 que es el timer
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_3
    clrf    dividir
    
    movf    modo, W	    //si modo=3 entra a ESTADO_4 donde se resetea
    movwf   dividir
    movlw   3
    subwf   dividir, F
    btfsc   ZERO
    call    ESTADO_4
    clrf    dividir
    goto    loop
    
//////////////////////////////////////////////////////////////////////////////// 
config_ports:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISD	    
    clrf    TRISC	    //los puertos A,C,D,E estan como salida
    clrf    TRISA
    clrf    TRISE
    
    bcf	    TRISD, 0
    bcf	    TRISD, 1	    //bits 0,1,2,3 de PORTD como salida,
    bcf	    TRISD, 2	    //cada uno es un digito del display
    bcf	    TRISD, 3
			    //bits de PORTB donde estan los push button
    bsf	    TRISB, 0	    //DISPLAY_UP
    bsf	    TRISB, 1	    //DISPLAY_DOWN
    bsf	    TRISB, 2	    //EDITAR/ACEPTAR
    bsf	    TRISB, 3	    //INICIAR/ACEPTAR
    bsf	    TRISB, 4	    //MODO
    
    bcf	    OPTION_REG, 7   //RBPU
    bsf	    WPUB, 0	    //abilitamos pull up en RB0,RB1,RB2,RB3,RB4
    bsf	    WPUB, 1
    bsf	    WPUB, 2
    bsf	    WPUB, 3
    bsf	    WPUB, 4
    
    banksel PORTA	    
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
			    //limpiamos todas las variables para que 
    clrf    Editar_Aceptar  //no empiezen con algun valor
    clrf    dividir
    clrf    cont1
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
    
    movlw   1		    //un mes no empieza en 00 sino que en 01
    movwf   dias	    //por eso movemos 1 a dias
    
    return
    
reloj:
    banksel OSCCON  //osciloscopio
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
    bsf	    TMR1IE	    //interrupcion TMR1
    bsf	    TMR2IE	    //interrupcion TMR2
    
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
    bcf	    TMR1IF	    //bandera en TMR1
    bcf	    TMR2IF
    return
////////////////////////////////////////////////////////////////////////////////
    
TMR2_LED:
    movf    cont1, W
    sublw   2		//250ms * 2 = 500ms
    btfsc   ZERO	//encinciendo led 500ms
    bsf	    PORTC, 0

    movf    cont1, W
    sublw   4		//250ms * 2 = 500ms
    btfss   ZERO	//apago led 500ms
    goto    $+3
    bcf	    PORTC, 0
    clrf    cont1
    
    return
    
MOSTRAR_VALOR:
    clrf    PORTD
    btfss   banderas, 0	    //limpiamos PORTD y dependiendo de la bandera,
    goto    display_0	    //vamos a una subtutina
			    //cada subrutina enciende un digito del display
    btfss   banderas, 1	    //y mueve lo que esta en "display" al PORTC
    goto    display_1	    //donde ya se muestra en el display
    
    btfss   banderas, 2
    goto    display_2
    
    btfss   banderas, 3
    goto    display_3
    
    display_0:
	movf	display, W	//aqui movemos lo que esta en display a W
	movwf	PORTC		//y eso lo movemos al PORTC donde esta el display
	bcf	PORTD, 0	//y encendemos el bit de PORTD
	bsf	banderas, 0	//donde queremos que se muestre el valor
	return

    display_1:
	movf	display+1, W
	movwf	PORTC
	bcf	PORTD, 1 
	bsf	banderas, 1
	return

    display_2:
	bsf	banderas, 2
	movf	display+2, W
	movwf	PORTC
	bcf	PORTD, 2
	return
    
    display_3:
	clrf	banderas
	movf	display+3, W
	movwf	PORTC
	bcf	PORTD, 3
	return

DISPLAY_SET:		    
    movf    nibbles, W	    //aqui movemos lo que esta en nibles a display
    call    tabla	    //son 4 de cada uno por ser en total 4 displays de
    movwf   display	    //7 segmentos que estamos usando
    
    movf    nibbles+1, W
    call    tabla
    movwf   display+1
    
    movf    nibbles+2, W
    call    tabla
    movwf   display+2
    
    movf    nibbles+3, W
    call    tabla
    movwf   display+3
    return
    
////////////////////////////////////////////////////////////////////////////////
		    
			//aqui estan los nibles de cada estado, dependiendo del
			//estado los valores de las variables se mueven a
			//la variable "nibble" que se muestra en el display
NIBBLE_RELOJ:
    movf    minutos, W	    	    
    movwf   nibbles	//si estamos en el estado 1, los minutos y segundos
			//del Reloj digital se mueve a nibbles
    movf    minutos+1, W
    movwf   nibbles+1	//minutos+1 y horas+1 representan los decimales 
    
    movf    horas, W
    movwf   nibbles+2
    
    movf    horas+1, W
    movwf   nibbles+3
    return
    
NIBBLE_FECHA:
    movf    dias, W	//si estamos en el estado 2, los dias y dividir_mes
    movwf   nibbles	//se mueven a los nibbles
			//dividir_mes es la representacion de mes que se 
    movf    dias+1, W	//mostrara en los displays
    movwf   nibbles+1
    
    movf    dividir_mes, W
    movwf   nibbles+2
    
    movf    dividir_mes+1, W
    movwf   nibbles+3
    return
    
NIBBLE_TIMER:
    movf    segundos_timer, W	//si estamdos en el estado 3, son los segundos 
    movwf   nibbles		//y minutos del TIMER que se mueven a los nibbles
    
    movf    segundos_timer+1, W
    movwf   nibbles+1
    
    movf    minutos_timer, W
    movwf   nibbles+2
    
    movf    minutos_timer+1, W
    movwf   nibbles+3
    return
    
////////////////////////////////////////////////////////////////////////////////
ESTADO_1:		    //RELOJ DIGITAL
    bsf	    PORTA,0	    //en el primer estado encendemos un led que 
    bcf	    PORTA,1	    //representa en que estado estamos
    bcf	    PORTA,2
    
    call    NIBBLE_RELOJ    //aqui elejimos los nibbles
    call    Reloj_Digitos   //aqui incrementamos las variables
    call    UN_DIA	    //aqui que pasa cuando llegamos a 00:00 o 24:00, que paso un dia
    call    UNDERFLOW_RELOJ //aqui realizamos 00-> 23 para horas y 00->59 para minutos
    
    return
    
ESTADO_2:		    //FECHA
    bcf	    PORTA,0	    //aqui llamamos una tabla llamada "MESES" que,
    bsf	    PORTA,1	    //dependiendo del valor de "mes", va a otra subrutina
    bcf	    PORTA,2	    //donde esta el mes que representa ese valor
			    //si mes=0 entonces es ENERO
    call    UNDERFLOW_FECHA
    movf    mes, W
    call    MESES
    
    call    NIBBLE_FECHA    //escojemos los nibbles
    call    Fecha_digitos   //incremento de variables y underflow
    
    return
    
ESTADO_3:		    //TIMER
    bcf	    PORTA,0	    
    bcf	    PORTA,1
    bsf	    PORTA,2
    call    NIBBLE_TIMER    //escogemos los nibbles
    call    TIMER_DIGITOS   //incremento de variables
    call    UNDERFLOW_TIMER //underflow de las variables
    call    INICIAR_ALARMA  //que inicie el timer y buzer/led
    
    return
    
ESTADO_4:		
    bcf	    PORTA,0
    bcf	    PORTA,1	    //aqui reseteamos modo
    bcf	    PORTA,2	    //y varias variables
    clrf    modo
    clrf    Editar_Aceptar
    
    clrf    nibbles
    clrf    nibbles+1
    clrf    nibbles+2
    clrf    nibbles+3
    
    return
    
////////////////////////////////////////////////////////////////////////////////
    
;*******************************************************************************
;----------------RELOJ DIGITAL--------------------------------------------------
;*******************************************************************************   

Reloj_Digitos:

    movf    segundos, W	    //como segundos se incrementa cada 1s por TMR1
    movwf   dividir	    //si llega a 60 incrementa minutos y limpia segundos
    movlw   60		    
    subwf   dividir, F	    //usamos "dividir" porque se realizan varias operaciones
    btfss   ZERO	    //de restar una variable con un numero, entonces 
    goto    $+3		    //lo utilizamos para que no de muchos problemas
    clrf    segundos
    incf    minutos
    clrf    dividir
    
    movf    minutos, W	    //cuando minutos llega a 10, minutos+1 se incrementa
    movwf   dividir	    //y limpiamos minutos, esto porque uno reprecenta
    movlw   10		    //las unidades y el otro los decimales
    subwf   dividir, F
    btfss   ZERO	    
    goto    $+3		    
    clrf    minutos
    incf    minutos+1
    clrf    dividir
  
    movf    minutos+1, W    //si minutos+1 llega a 6, que representa 60,
    movwf   dividir	    //incrementa horas y limpia minutos+1
    movlw   6		    
    subwf   dividir, F	    
    btfss   ZERO	    
    goto    $+3
    clrf    minutos+1
    incf    horas
    clrf    dividir
    
    movf    horas, W	    //si horas llega a 10, incrementa horas+1,
    movwf   dividir	    //que representa los decimales, y limpiamos horas
    movlw   10
    subwf   dividir, F
    btfss   ZERO	   
    goto    $+3		   
    clrf    horas
    incf    horas+1
    clrf    dividir
    
    return
    
UN_DIA:
    movf    horas+1, W	    //Aqui revisamos si ya pasaron 24 horas, un dia total
    movwf   dividir	    //primero revisamos horas+1 si es 2, que equivale 20
    movlw   2	    	    //luego revisamos si horas es 4, junto con esto 
    subwf   dividir, F	    //equivale a 24 horar, entramos a REINICIO_RELOJ
    btfss   ZERO	    
    goto    $+7   

    movf    horas, W
    movwf   dividir	    
    movlw   4	    	    
    subwf   dividir, F	    
    btfsc   ZERO	    
    call    REINICIO_reloj
    clrf    dividir
    return

REINICIO_reloj:
    incf    dias	    //aqui reseteamos todas las variables relacionadas
    clrf    segundos	    //con el reloj digital
    clrf    minutos	    //tambien incrementamos la variable "dias"
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
				
    movf    minutos, W	    //si decrementamos una variable que esta en 0
    movwf   dividir	    //hay un underflow y la variable va a 255
    movlw   255		    //con esta idea es que chequeamos cada variable
    subwf   dividir, F	    //para que realize esto:	00->59
    btfss   CARRY	    //en este caso los minutos de 00 a 50
    goto    $+5		    //y las horas de 00 a 23
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
    
    movf    horas, W	    //tambien aqui decrementamos minutos+1, horas
    movwf   dividir	    //y horas+1 cuando estamos decrementamos 
    movlw   255		    //con los push button las variables horas y minutos
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
    
    
;*******************************************************************************
;----------------FECHA----------------------------------------------------------
;*******************************************************************************
    
Fecha_digitos:
		
    movf    dias, W	    //aqui realalizamos como lo que hicimos en reloj
    movwf   dividir	    //si dias es 10, incrementamos dias+1 y
    movlw   10		    //limpiamos dias
    subwf   dividir, F	    //en este caso mes y dividir_mes son utilizados de 
    btfss   ZERO	    //forma diferente
    goto    $+3
    clrf    dias
    incf    dias+1
    clrf    dividir
    return    
  
UNDERFLOW_FECHA:
    movf    dias, W	    //aqui realizamos el underflor de dias y mes
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
    
    movf    mes,W	    //dividir_mes se modifica en la tabla "MESES"
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
    movf    dias+1, W	    //aqui realizamos el overflow de dias
    movwf   dividir	    //algunos meses tienen 30 o 31 dias
    movlw   3		    //dependiento de eso el overflow de dias
    subwf   dividir, F	    //es 31 en los meses que tienen 30 dias
    btfss   CARRY
    goto    $+13
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   1
    subwf   dividir, F
    btfss   CARRY    
    goto    $+6
    incf    mes
    clrf    dias
    clrf    dias+1
    movlw   1
    addwf   dias
    clrf    dividir
    
    movf    dias+1, W	    //aqui tambien esta el underflow, pero en este caso 
    movwf   dividir	    //revisa si dias+1 y dias son ambos 0
    movlw   0		    //los cambia a 30
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
    movf    dias+1, W	    //aqui esta el overflow y underflow de los meses
    movwf   dividir	    //que tienen 31 dias, en este caso
    movlw   3		    //su overflow es de 32 dias
    subwf   dividir, F	    //y cuando ambos dias+1 y dias son 0
    btfss   CARRY	    //su underflow los cambia a 31
    goto    $+13
    clrf    dividir
    
    movf    dias, W
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfss   CARRY    
    goto    $+6
    incf    mes		    //tambien incrementamos mes porque es el ultimo dia
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


ENERO:			    //aqui con la tabla "MESES" llamamos una de estas 
    clrf    dividir_mes+1   //subrutinas llamadas los meses del año
    movlw   1		    //donde movemos a dividir_mes el numero que 
    movwf   dividir_mes	    //representa ese mes
			    //al igual de llamar la subrutina de los dias
    call    DIAS_31	    //que tiene ese mes, ENERO tiene 31 dias
    return

FEBRERO:
    clrf    dividir_mes+1   //Febrero es diferente porque tiene 28 dias y es 
    movlw   2		    //el unico con esta cantidad de dias
    movwf   dividir_mes	    //por eso en esta subrutina esta el overflow y 
			    //underflow de febrero
    movf    dias+1, W
    movwf   dividir
    movlw   2
    subwf   dividir, F
    btfss   CARRY
    goto    $+13
    clrf    dividir
    
    movf    dias, W
    movwf   dividir	    //revisa si dias es 29
    movlw   9
    subwf   dividir, F
    btfss   CARRY   
    goto    $+6
    incf    mes		    //tambien incrementamos mes
    clrf    dias
    clrf    dias+1
    movlw   1
    addwf   dias
    clrf    dividir
    
    movf    dias+1, W
    movwf   dividir	    //revisa si dias es 00
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
    
    movf    dias+1, W	    //aqui revisa si dias+1 es 3, que equivale 30
    movwf   dividir	    //llaque al incrementar mes con Editar_Aceptar
    movlw   3		    //puede que estemos fuera del rango de dias que
    subwf   dividir, F	    //tiene febrero y aqui lo regresamos a 28
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
    clrf    dividir_mes+1   //mes de marzo dividir_mes=03
    movlw   3
    movwf   dividir_mes
    
    call    DIAS_31
    return
ABRIL:			    //abril dividir_mes=04
    clrf    dividir_mes+1
    movlw   4
    movwf   dividir_mes
    
    call    DIAS_30
    return
    
MAYO:			    //mayo dividir_mes=05
    clrf    dividir_mes+1
    movlw   5
    movwf   dividir_mes
    
    call    DIAS_31
    return
    
JUNIO:			    //junio dividir_mes=06
    clrf    dividir_mes+1
    movlw   6
    movwf   dividir_mes
    
    call    DIAS_30
    return
    
JULIO:			    //julio dividir_mes=07
    clrf    dividir_mes+1
    movlw   7
    movwf   dividir_mes
    
    call    DIAS_31
    return
    
AGOSTO:			    //agosto dividir_mes=08
    clrf    dividir_mes+1
    movlw   8
    movwf   dividir_mes
    
    call    DIAS_31
    return
    
SEPTIEMBRE:		    //septiembre dividir_mes=09
    clrf    dividir_mes+1
    movlw   9
    movwf   dividir_mes
    
    call    DIAS_30
    return
    
OCTUBRE:		    //octubre dividir_mes=10
    clrf    dividir_mes
    movlw   1
    movwf   dividir_mes+1
    
    call    DIAS_31
    return
    
NOVIEMBRE:		    //noviembre dividir_mes=11
    movlw   1
    movwf   dividir_mes
    movlw   1
    movwf   dividir_mes+1
    
    call    DIAS_30
    return

DICIEMBRE:		    //diciembre dividir_mes=12
    movlw   2
    movwf   dividir_mes
    movlw   1
    movwf   dividir_mes+1
    
    call    DIAS_31
    return
    
RESET_MES:		    //aqui si mes es 13, lo reseteamos
    clrf    mes
    clrf    Editar_Aceptar
    
    movlw   1		    //aqui si estamos incrementando mes, 
    movwf   Editar_Aceptar  //por usar PCLATH no limpie la variable
    return

;*******************************************************************************
;----------------TIMER----------------------------------------------------------
;*******************************************************************************

TIMER_DIGITOS:
    movf    segundos_timer+1, W	    
    movwf   dividir		//aqui tenemos el overflow del TIMER,
    movlw   6			//donde si segundos_timer es 10 incrementa 
    subwf   dividir, F		//seguntos_timer+1 y si este es 6
    btfss   ZERO		//incrementa minutos_timer
    goto    $+3			//siendo minutos_timer+1 su decimal
    clrf    segundos_timer+1
    incf    minutos_timer
    clrf    dividir
    
    movf    segundos_timer, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	   
    goto    $+3		   
    clrf    segundos_timer
    incf    segundos_timer+1
    clrf    dividir
    
    movf    minutos_timer, W
    movwf   dividir
    movlw   10
    subwf   dividir, F
    btfss   ZERO	    
    goto    $+3		    
    clrf    minutos_timer
    incf    minutos_timer+1
    clrf    dividir
    
    movf    minutos_timer+1,W	//en este caso el max. tiempo del timer es 99:59
    movwf   dividir		//por lo que si minutos_timer+1 llega a 10
    movlw   10			//que equivale a A0:00, reinicia el timer
    subwf   dividir, F
    btfsc   ZERO
    goto    REINICIO_TIMER
    clrf    dividir
    return

UNDERFLOW_TIMER:			
    movf    segundos_timer, W	//este es el underflow del timer y tiene la     
    movwf   dividir		//misma dinamica que el underflow del Reloj 
    movlw   255			//si una variable llega a 255 lo limpia eh
    subwf   dividir, F		//decrementa la siguiente variable
    btfss   CARRY	    
    goto    $+5
    clrf    segundos_timer
    decf    segundos_timer+1
    movlw   9
    addwf   segundos_timer
    clrf    dividir
    
    movf    segundos_timer+1, W	    
    movwf   dividir
    movlw   255		    
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    decf    minutos_timer
    clrf    segundos_timer+1
    movlw   5
    addwf   segundos_timer+1
    clrf    dividir
    
    movf    minutos_timer, W	//en este caso al realizar el underflow las     
    movwf   dividir		//las variables cambian de 00:00 -> 99:59
    movlw   255		    
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+5
    clrf    minutos_timer
    decf    minutos_timer+1
    movlw   9
    addwf   minutos_timer
    clrf    dividir
    
    movf    minutos_timer+1, W	   
    movwf   dividir
    movlw   255		    
    subwf   dividir, F
    btfss   CARRY	    
    goto    $+4
    clrf    minutos_timer+1
    movlw   9
    addwf   minutos_timer+1
    clrf    dividir
				    
    return

INICIAR_ALARMA:
    movf    alarma, W		//aqui revisamos la alarma y dependiendo de su valor
    movwf   dividir		//iniciamos oh detenemos el timer y el buzer/led
    movlw   1
    subwf   dividir, F		//si la variable es 1 sabemos que entonces, por 
    btfss   ZERO		//interrupcion de TMR1 decrementa segundos_timer
    goto    $+32		//cada 1s
    clrf    dividir
    
	movf	minutos_timer+1, W
	movwf	dividir
	movlw	0
	subwf	dividir, F
	btfss	ZERO
	goto	$+25
	clrf	dividir
	
	    movf	minutos_timer, W    //como alarma es 1 tambien chequeamos 
	    movwf	dividir		    //si todas las variables de TIMER
	    movlw	0		    //son 0
	    subwf	dividir, F
	    btfss	ZERO
	    goto	$+18
	    clrf	dividir

		movf	segundos_timer+1, W
		movwf	dividir
		movlw	0
		subwf	dividir, F
		btfss	ZERO
		goto	$+11
		clrf	dividir

		    movf	segundos_timer, W
		    movwf	dividir
		    movlw	0
		    subwf	dividir, F
		    btfss	ZERO
		    goto	$+4
		    call	REINICIO_TIMER	//si todas las variables son 0, las limpiamos todas
		    incf    	alarma		//incrementamos alarma otra ves, entonces
		    incf	parar_timer	//alarma = 2, no hace nada
		    clrf	dividir		//eh incrementamos parar_timer
    
		    
		    
    movf    alarma, W	    //aqui vemos si alarma es 3, paramos el timer
    movwf   dividir	    //y paramos el buzer/led que se activo cuando el 
    movlw   3		    //timer llego a 00:00
    subwf   dividir, F
    btfss   ZERO	    
    goto    $+5
    bcf	    PORTE, 2
    clrf    apagar_led
    clrf    parar_timer
    clrf    alarma
    clrf    dividir
    
    movf    apagar_led, W   //si parar_timer es 1 entonces la variable apagar_led
    movwf   dividir	    //se incrementa cada 1s, entonces cuando llega a 60
    movlw   60		    //que equivale a 1 minutos, entonces limpia
    subwf   dividir, F	    //las variables y apaga el buzer/led
    btfss   ZERO
    goto    $+5
    bcf	    PORTE, 2
    clrf    apagar_led
    clrf    parar_timer
    clrf    alarma
    clrf    dividir
    return
    
REINICIO_TIMER:
    clrf    segundos_timer
    clrf    minutos_timer
    clrf    segundos_timer+1
    clrf    minutos_timer+1
    clrf    nibbles
    clrf    nibbles+1
    clrf    nibbles+2
    clrf    nibbles+3
    return

    
;-------------------------------------------------------------------------------    
//ORG 600h
MESES:
    clrf    PCLATH		; Limpiamos registro PCLATH
    bsf	    PCLATH, 2		; Posicionamos el PC en dirección 02xxh
    andlw   0x0F		; no saltar más del tamaño de la tabla
    addwf   PCL
    goto    ENERO		//aqui es donde, dependiendo de la variable mes
    goto    FEBRERO		//nos dirigimos a la subrutina, que es el 
    goto    MARZO		//mes que queremos
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

