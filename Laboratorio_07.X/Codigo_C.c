/*
 * File:   Codigo_C.c
 * Author: HP
 *
 * Created on 2 de abril de 2022, 02:03 PM
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
//#define _tmr0_value 61
                     //0     1    2    3    4   5    6    7     8   9   
const char tabla[] = {0xFC,0x60,0xDA,0xF2,0x66,0xB6,0xBE,0xE0,0xFE,0xF6,
                    0xEE,0x3E,0x9C,0x7A,0x9E,0x8E};
                    //A    B   C   D    E    F
void setup(void);

void __interrupt() isr (void){
    if(INTCONbits.RBIF){        // Fue interrupción del PORTB
        if (!PORTBbits.RB0)             // Verificamos si fue RB0 quien generó la interrupción
            ++PORTA;            // Incremento del PORTC
        if(!PORTBbits.RB1)
            --PORTA;
        INTCONbits.RBIF = 0;    // Limpiamos bandera de interrupción
    }
    
    return;
}

void main(void) {
    setup();
    
    while(1){
        
    }
    return;
}

void setup(void){
    
    ANSEL = 0x00;
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0x00;
    TRISC = 0x00;
    TRISD = 0x00;
    
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;
    
    TRISBbits.TRISB0 = 1;
    TRISBbits.TRISB1 = 1;
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB = 0x03;   //0011 RB0 y RB1
    IOCBbits.IOCB = 0x03;   //RB0 y 
    /*
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PS = 0b0111; //PSA =0 , PS2,PS1,PS0 = 111; 1:256
    TMR0 = _tmr0_value;*/
    
    INTCONbits.GIE  = 1;         
    INTCONbits.RBIE = 1;         
    INTCONbits.RBIF = 0;
    /*INTCONbits.T0IF = 0;
    INTCONbits.T0IE = 1;*/
}
