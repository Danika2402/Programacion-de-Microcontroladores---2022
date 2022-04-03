/*
 * File:   Ej_04.c
 * Author: HP
 *
 * Created on 28 de marzo de 2022, 10:57 PM
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

#define _XTAL_FREQ 4000000

#include <xc.h>
#include <stdint.h>

uint8_t contador=0;
uint8_t comparar=0;
const char valores[10] = {19,7,3,10,15,1,6,18,20,14};

void setup(void);

void __interrupt() isr (void){
    
    if(INTCONbits.RBIF){        // Fue interrupción del PORTB
        if (!PORTBbits.RB0)             // Verificamos si fue RB0 quien generó la interrupción
            ++contador;            // Incremento del PORTC
        if(!PORTBbits.RB1)
            --contador;
        
        INTCONbits.RBIF = 0;    // Limpiamos bandera de interrupción
    }
    
    return;
}


void main(void) {
    setup();

    while(1){
        PORTA = contador;
        //contador = (contador == 21)? 0:contador;
        //contador = (contador == 255)? 20:contador;
        if(contador==21)
            contador=0;
        if(contador==255)
            contador=20;
        
        for(uint8_t i=0; i<7;++i){
            
            if(contador == valores[i])
                comparar = i;
        }
        PORTC = comparar;
        
    }
    
    return;
}


void setup(void){
    
    ANSEL = 0x00;
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0110;   //4MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0x00;
    TRISB = 0x00;
    TRISC = 0x00;
    
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    
    TRISBbits.TRISB0 = 1;
    TRISBbits.TRISB1 = 1;
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB0 = 1;
    WPUBbits.WPUB1 = 1;
    IOCBbits.IOCB0 = 1;
    IOCBbits.IOCB1 = 1;
    
    INTCONbits.GIE  = 1;         
    INTCONbits.RBIE = 1;         
    INTCONbits.RBIF = 0;
    
    return;
}

