/*
 * File:   SPI_SLAVE_2.c
 * Author: HP
 *
 * Created on 10 de mayo de 2022, 12:28 AM
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
#define FLAG_SPI 0xDD

#define IN_MIN 0                // Valor minimo de entrada del potenciometro
#define IN_MAX 255              // Valor maximo de entrada del potenciometro
#define OUT_MIN 62              // Valor minimo de ancho de pulso de señal PWM
#define OUT_MAX 125             // Valor maximo de ancho de pulso de señal PWM

void setup(void);
unsigned short map(uint8_t val, uint8_t in_min, uint8_t in_max, 
            unsigned short out_min, unsigned short out_max);
uint8_t PWM;
uint8_t val_temporal;
unsigned short CCP1;

void __interrupt() isr (void){
    if (PIR1bits.SSPIF){
        while (!SSPSTATbits.BF){}
        PWM = SSPBUF;

        __delay_ms(10);
        
        PIR1bits.SSPIF = 0;
    }
}

void main(void) {
    setup();
    
    while(1){
        
        CCP1 = map(PWM, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); //mapeamos valor de potenciometro
        CCPR1L = (uint8_t)(CCP1>>2);    
        CCP1CONbits.DC1B = CCP1 & 0b11; 
        
    }
    return;
}

void setup(void){
    ANSELH = 0x00;
    ANSEL = 0x00;
    
    TRISA = 0b00100000;
    PORTA = 0X00;
    
    TRISC = 0b00011000; // -> SDI y SCK entradas, SD0 como salida
    PORTC = 0x00;
        
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
     
    // SSPCON <5:0>
    SSPCONbits.SSPM = 0b0100;   // -> SPI Esclavo, SS hablitado
    SSPCONbits.CKP = 0;         // -> Reloj inactivo en 0
    SSPCONbits.SSPEN = 1;       // -> Habilitamos pines de SPI
    // SSPSTAT<7:6>
    SSPSTATbits.CKE = 1;        // -> Dato enviado cada flanco de subida
    SSPSTATbits.SMP = 0;        // -> Dato al final del pulso de reloj
    
    //Configuracion PWM
    TRISCbits.TRISC2 = 1;       //Deshabilitar salida CCP1
    PR2 = 155;                  //periodo 10ms
    
    //Configuracion CCP
    CCP1CON = 0;                //Apagamos CCP1
    CCP1CONbits.P1M = 0;        //modo single output
    CCP1CONbits.CCP1M = 0b1100; //PWM CCP1
    
    CCPR1L = 125>>2;
    CCP1CONbits.DC1B = 125 & 0b11; //2ms ancho de pulso, 20% duty cycle
    
    PIR1bits.TMR2IF = 0;        //bandera TMR2
    T2CONbits.T2CKPS = 0b11;    //prescaler 1:16
    T2CONbits.TMR2ON = 1;       //encender TMR2
    while(!PIR1bits.TMR2IF);
    PIR1bits.TMR2IF = 0;        //Esperar ciclo TMR2
    
    TRISCbits.TRISC1 = 0;       //Habilitar salida CCP2
    
    //Configuraciones de interrupcioens
    //PIR1bits.ADIF = 0;          //bandera int. ADC
    //PIE1bits.ADIE = 1;          //habilitar int. ADC
    PIR1bits.SSPIF = 0;         // Limpiamos bandera de SPI
    PIE1bits.SSPIE = 1;         // Habilitamos int. de SPI
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales

}

// y = y0 + [(y1 - y0)/(x1-x0)]*(x-x0)

unsigned short map(uint8_t x, uint8_t x0, uint8_t x1, 
            unsigned short y0, unsigned short y1){
    return (unsigned short)(y0+((float)(y1-y0)/(x1-x0))*(x-x0));
}