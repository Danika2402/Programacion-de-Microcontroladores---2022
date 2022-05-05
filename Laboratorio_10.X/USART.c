/*
 * File:   USART.c
 * Author: HP
 *
 * Created on 30 de abril de 2022, 09:59 PM
 */

#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

#define _XTAL_FREQ 1000000

#include <xc.h>
#include <stdint.h>
void setup(void);

uint8_t unidad, decena, centena;
uint8_t indice, pot, ASCII;
uint8_t inicio = 0;

void Print(char *str);
void TX(char dato);

void __interrupt() isr (void){
    if(PIR1bits.RCIF){          //esperamos un dato y lo guardamos en una variable
        indice = RCREG;         //ASCII es para un case 
        ASCII =0;
    }
    else if(PIR1bits.ADIF){     //ADC en RA0 donde guardamos el valor del potenciometro
        if(ADCON0bits.CHS == 0)     //en una variable
            pot = ADRESH;        
        PIR1bits.ADIF = 0;    
    }
    return;
}
    
void main(void) {
    setup();
    
    while(1){
        if(ADCON0bits.GO == 0){    //Solo usamos un canal          
            ADCON0bits.GO = 1;              
        }
        
        centena = pot/100;                            
        decena = (pot - (100 * centena))/10;         
        unidad = pot - (100 * centena)-(10 * decena);
        
        centena += 48;      //La terminal utiliza formato ASCII y el 48 es 
        decena += 48;       //en numero 0 en ese formato, por eso lo sumamos
        unidad += 48;       //a las variables despues de hacer la conversion 
                            //para que sea de 0 a 255
        if(inicio==0){
            Print("1. Leer Potenciometro\r");   //Utilizamos la variable para que 
            Print("2. Enviar Ascii\r");         //la terminal no este imprimiendo 
            inicio = 1;                         //infinitamente sin pausa
        }
        
        if(PIR1bits.RCIF == 0){             //Aqui chequeamos si recivimos un dato,
            switch(indice){                 //dependiendo de este vamos  un "case"
                case('1'):
                    Print("\r");            //Si recibimos 1 entonces subimos
                    TX(centena);            //el valor del potenciometro a la terminal
                    TX(decena);             //que fue dividido en 3 variables para 
                    TX(unidad);             //que se pueda imprimir
                    Print("\rListo\r\r");
                    inicio = 0;             //Limpiamos indice para que no se realize
                    indice = 0;             //un loop continuo
                    break;

                case('2'):
                    Print("\rIngresa un dato\r");   //Si es 2, entramos en otro mini loop
                    ASCII = 1;                      //donde la variable es usada para quedarnos en el loop
                    while(ASCII ==1);               //que solo termina en la interrupcion
                        //PORTD = RCREG;            //que cambia el valor de la variable
                                                   //con eso se sube el caracter al    
                    PORTD = RCREG;                  //puerto D y reiniciamos todo
                    Print("Listo\r\r");
                    inicio = 0;
                    indice = 0;
                    break;
            }
        }
    }
    return;
}

void setup(void){
    
    ANSEL =0b00000001;      //AN0 
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00000001;     //RA0 
    TRISD = 0x00;
    PORTD = 0x00;
    PORTA = 0x00;

    //Configuraciones de ADC
    ADCON0bits.ADCS = 0b00;     // Fosc/2
    
    ADCON1bits.VCFG0 = 0;       //VDD *Referencias internas
    ADCON1bits.VCFG1 = 1;       //VSS
    
    ADCON0bits.CHS = 0b0000;    //canal AN0
    ADCON1bits.ADFM = 0;        //justificacion Izquierda
    ADCON0bits.ADON = 1;        //habilitar modulo ADC
    __delay_us(40);
    
    // Configuraciones de comunicacion serial
    TXSTAbits.SYNC = 0;         // Comunicación ascincrona (full-duplex)
    TXSTAbits.BRGH = 1;         // Baud rate de alta velocidad 
    BAUDCTLbits.BRG16 = 1;      // 16-bits para generar el baud rate
    
    SPBRG = 25;
    SPBRGH = 0;                 // Baud rate 9600, error 0.16%
    
    RCSTAbits.SPEN = 1;         // Habilitamos comunicación
    TXSTAbits.TX9 = 0;          // Utilizamos solo 8 bits
    TXSTAbits.TXEN = 1;         // Habilitamos transmisor
    RCSTAbits.CREN = 1;         // Habilitamos receptor
    
    PIR1bits.ADIF = 0;          //bandera int. ADC
    PIE1bits.ADIE = 1;          //habilitar int. ADC
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales
    PIE1bits.RCIE = 1;          // Habilitamos Interrupciones de recepción
    
    return;
}

void Print(char *str){
        while(*str != '\0'){    //Utilizamos estas subrutinas para mandar caracteres
            TX(*str);           //a la terminal, donde se utiliza un puntero que incrementa
            str++;              //entonces esto selecciona cada caracter 
        }
}

void TX(char dato){
    
    while(TXSTAbits.TRMT==0);   //aqui enviamos caracter por caracter lo que queremos
        TXREG = dato;           //imprimir
}
