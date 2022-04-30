/*
 * File:   PWM.c
 * Author: HP
 *
 * Created on 24 de abril de 2022, 02:00 PM
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

#define _tmr0_value 255 //1ms
#define _XTAL_FREQ 1000000

#include <xc.h>
#include <stdint.h>
void setup(void);
unsigned short map(uint8_t val, uint8_t in_min, uint8_t in_max, 
            unsigned short out_min, unsigned short out_max);

#define IN_MIN 0                // Valor minimo de entrada del potenciometro
#define IN_MAX 255              // Valor maximo de entrada del potenciometro
#define OUT_MIN 62              // Valor minimo de ancho de pulso de señal PWM
#define OUT_MAX 125             // Valor maximo de ancho de pulso de señal PWM

#define OUT_TMR0_MAX 2

unsigned short CCP1,CCP2, pot3,pot;            // Variable para almacenar ancho de pulso al hacer la interpolaci lineal

void __interrupt() isr (void){
    if(PIR1bits.ADIF){                      
        if(ADCON0bits.CHS == 0){            
            CCP1 = map(ADRESH, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); //mapeamos valor de potenciometro
            CCPR1L = (uint8_t)(CCP1>>2);    
            CCP1CONbits.DC1B = CCP1 & 0b11; 
        }else if(ADCON0bits.CHS == 1){
            CCP2 = map(ADRESH, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); 
            CCPR2L = (uint8_t)(CCP2>>2);    
            CCP2CONbits.DC2B0 = CCP2 & 0b01;
            CCP2CONbits.DC2B1 = CCP2 & 0b10;
        }else if(ADCON0bits.CHS == 2){
            pot = map(ADRESH, IN_MIN, IN_MAX, IN_MIN, OUT_TMR0_MAX);
            
            if(pot3 < pot)
                PORTCbits.RC3 = 1;
            else
                PORTCbits.RC3 = 0;
        
        }
        PIR1bits.ADIF = 0;                 
    }
    else if(INTCONbits.T0IF){
        ++pot3;
        //++PORTD;
        if(pot3 == 20)      
            pot3=0;
        
        INTCONbits.T0IF = 0;
        TMR0 = _tmr0_value;     //1ms incrementamos variable
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
                ADCON0bits.CHS = 0b0010;
            else if(ADCON0bits.CHS == 0b0010)
                ADCON0bits.CHS = 0b0000;
            
            __delay_us(40);
            ADCON0bits.GO = 1;
        }
    }
    return;
}

void setup(void){
    ANSEL =0b00000111;      //AN0 AN1 AN2
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00000111;     //RA1 y RA0 RA2
    PORTA = 0x00;
    TRISCbits.TRISC3 = 0;
    PORTC = 0x00;
    //configuracion TMR0
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0; 
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;     //Prescaler = 1:256
    TMR0 = _tmr0_value;         //2ms
            
    
    //Configuraciones de ADC
    ADCON0bits.ADCS = 0b00;     // Fosc/2
    
    ADCON1bits.VCFG0 = 0;       //VDD *Referencias internas
    ADCON1bits.VCFG1 = 0;       //VSS
    
    ADCON0bits.CHS = 0b0000;    //canal AN0
    ADCON1bits.ADFM = 0;        //justificacion Izquierda
    ADCON0bits.ADON = 1;        //habilitar modulo ADC
    __delay_us(40);
    
    //Configuracion PWM
    TRISCbits.TRISC2 = 1;       //Deshabilitar salida CCP1
    TRISCbits.TRISC1 = 1;       //Deshabilitar salida CCP2
    PR2 = 155;                  //periodo 10ms
    
    //Configuracion CCP
    CCP1CON = 0;                //Apagamos CCP1
    CCP2CON = 0;                //Apagamos CCP2
    CCP1CONbits.P1M = 0;        //modo single output
    CCP1CONbits.CCP1M = 0b1100; //PWM CCP1
    CCP2CONbits.CCP2M = 0b1100; //PWM CCP2
    
    CCPR1L = 125>>2;
    CCP1CONbits.DC1B = 125 & 0b11; //2ms ancho de pulso, 20% duty cycle
    
    CCPR2L = 125>>2;
    CCP2CONbits.DC2B0 = 125 & 0b1; //2ms ancho de pulso, 20% duty cycle
    CCP2CONbits.DC2B1 = 125 & 0b1;
    
    PIR1bits.TMR2IF = 0;        //bandera TMR2
    T2CONbits.T2CKPS = 0b11;    //prescaler 1:16
    T2CONbits.TMR2ON = 1;       //encender TMR2
    while(!PIR1bits.TMR2IF);
    PIR1bits.TMR2IF = 0;        //Esperar ciclo TMR2
    
    TRISCbits.TRISC2 = 0;       //Habilitar salida CCP1
    TRISCbits.TRISC1 = 0;       //Habilitar salida CCP2
    
    //Configuraciones de interrupcioens
    PIR1bits.ADIF = 0;          //bandera int. ADC
    PIE1bits.ADIE = 1;          //habilitar int. ADC
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales
    INTCONbits.T0IF = 0;        //bandera int. TMR0
    INTCONbits.T0IE = 1;        //habilitar int. TMR0
    return;
}

// y = y0 + [(y1 - y0)/(x1-x0)]*(x-x0)

unsigned short map(uint8_t x, uint8_t x0, uint8_t x1, 
            unsigned short y0, unsigned short y1){
    return (unsigned short)(y0+((float)(y1-y0)/(x1-x0))*(x-x0));
}