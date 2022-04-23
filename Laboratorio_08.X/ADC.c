/*
 * File:   ADC.c
 * Author: HP
 *
 * Created on 15 de abril de 2022, 06:14 PM
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

#define _tmr0_value 252//159    4ms
#define _XTAL_FREQ 1000000

#include <xc.h>
#include <stdint.h>
void setup(void);

const char tabla[] = {0xFC,0x60,0xDA,0xF2,0x66,0xB6,0xBE,0xE0,0xFE,0xF6,
                    0xEE,0x3E,0x9C,0x7A,0x9E,0x8E};

uint8_t unidad, decena, centena,pot2;
uint8_t display;

void __interrupt() isr (void){
    if(PIR1bits.ADIF){
        if(ADCON0bits.CHS == 0)     //utilizamos 2 canales donde cada uno tiene 
            PORTB = ADRESH;         //un potenciometro de 1k, dependiendo de cual canal
        else if(ADCON0bits.CHS == 1)//se utiliza guardamos ADRESH del pot1 en el PORTB 
            pot2 = ADRESH;          //y del pot2 en una variable
        PIR1bits.ADIF = 0;    
    }
    
    else if(INTCONbits.T0IF){   //Chequear si se prendio la bandera
        PORTD = 0x00;           //limpiar PORTD
        if(display==1){                 //Incrementamos display cada 4ms
            RD2 = 1;                    //y dependiendo de su valor
            PORTC = (tabla[unidad]);    //encendemos el bit de PORTD
        }else if(display==2){           //donde se encuentra el digito
            RD1 = 1;                    //del displayd de 7 segmentos
            PORTC = (tabla[decena]);    //y movemos a PORTC el valor
        }else if(display ==3){
            RD0 = 1;
            PORTC = (tabla[centena]);
            RC0 = 1;
        }else if(display == 4){
            display = 0;
        }
        ++display;
        INTCONbits.T0IF = 0;
        TMR0 = _tmr0_value;     //4ms
    }
    
    return;
}

void main(void) {
    setup();
    
    while(1){
        if(ADCON0bits.GO == 0){
            if(ADCON0bits.CHS == 0b0000)        //cambianos de un canal al otro
                ADCON0bits.CHS = 0b0001;        //siempre con un delay 
            else if(ADCON0bits.CHS == 0b0001)
                ADCON0bits.CHS = 0b0000;
            __delay_us(40);
            ADCON0bits.GO = 1;
        }
    
        centena = (uint8_t)((pot2*1.9607)/100);                            
        decena = (uint8_t)(((pot2*1.9607) - (100 * centena))/10);         
        unidad = (uint8_t)((pot2*1.9607) - (100 * centena)-(10 * decena));
        
        if(centena > 9)    //como ADC es de 8 bits, utilizamos centenas, decenas
            centena=0;      //y unidades, para comvertir de 255->500
        if(decena > 9)     //lo multiplicamos por 1.9607
            decena=0;       //tambien chequeamos si es mayor de 15 la variable
        if(unidad > 9)     //para que no quiebre el programa
            unidad=0;
        
    }
    
    return;
}

void setup(void){
    ANSEL =0b00000011;      //AN0 y AN1
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00000011;     //RA1 y RA0
    TRISB = 0x00;
    TRISC = 0x00;
    TRISD = 0x00;
    
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;
    
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0; 
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;     //Prescaler = 1:256
    TMR0 = _tmr0_value;         //4ms
            
    //Configuraciones de ADC
    ADCON0bits.ADCS = 0b00;     // Fosc/2
    
    ADCON1bits.VCFG0 = 0;       //VDD *Referencias internas
    ADCON1bits.VCFG1 = 1;       //VSS
    
    ADCON0bits.CHS = 0b0000;    //canal AN0
    ADCON1bits.ADFM = 0;        //justificacion Izquierda
    ADCON0bits.ADON = 1;        //habilitar modulo ADC
    __delay_us(40);
    
    //Configuraciones de interrupcioens
    PIR1bits.ADIF = 0;          //bandera int. ADC
    PIE1bits.ADIE = 1;          //habilitar int. ADC
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales
    INTCONbits.T0IF = 0;        //bandera int. TMR0
    INTCONbits.T0IE = 1;        //habilitar int. TMR0
    
    return;
}
