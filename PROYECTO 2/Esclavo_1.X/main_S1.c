/*
 * File:   main_S1.c
 * Author: HP
 *
 * Created on 25 de mayo de 2022, 01:57 PM
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

uint8_t dato,check, POT1,POT2,old_dato;
#define READ 0b0
#define WRITE 0b1

void setup(void);
void SERVO_1(uint8_t val);
void SERVO_2(uint8_t val);
unsigned short map(uint8_t val, uint8_t in_min, uint8_t in_max, 
            unsigned short out_min, unsigned short out_max);

#define IN_MIN 0                // Valor minimo de entrada del potenciometro
#define IN_MAX 127              // Valor maximo de entrada del potenciometro
#define OUT_MIN 0              // Valor minimo de ancho de pulso de señal PWM
#define OUT_MAX 125             // Valor maximo de ancho de pulso de señal PWM

unsigned short CCP1,CCP2;            // Variable para almacenar ancho de pulso al hacer la interpolaci lineal

void __interrupt() isr (void){

    if (PIR1bits.SSPIF){
        SSPCONbits.CKP = 0;         // Mantenemos el reloj en 0 para que se configure el esclavo
        
        if ((SSPCONbits.SSPOV) || (SSPCONbits.WCOL)){
            uint8_t var = SSPBUF;   // Limpiamos el buffer
            SSPCONbits.SSPOV = 0;   // Limpiamos bandera de overflow
            SSPCONbits.WCOL = 0;    // Limpiamos indicador de colisi n�
            SSPCONbits.CKP = 1;     // Habilitamos reloj para recibir datos
        }
        
        // Verificamos lo recibido fue un dato y no una direcci n�
        // Verificamos si el esclavo tiene que recibir datos del maestro
        if(!SSPSTATbits.D_nA && !SSPSTATbits.R_nW){
            SSPSTATbits.BF = 0;     // Limpiamos bandera para saber cuando se reciben los datos
            while(!SSPSTATbits.BF); // Esperamos a recibir los datos
            dato=(SSPBUF);         // Mostramos valor recibido del mestro en PORTD
            SSPCONbits.CKP = 1;     // Habilitamos el reloj
        }
        
        // Verificamos lo recibido fue un dato y no una direcci n�
        // Verificamos si el esclavo tiene que enviar datos al maestro
        /*else if(!SSPSTATbits.D_nA && SSPSTATbits.R_nW){
            SSPBUF = cont ;         // Preparamos dato a enviar
            SSPCONbits.CKP = 1;     // Habilitamos reloj para el env o�
            while(SSPSTATbits.BF);  // Esperamos a que se env e el dato�
            PORTA = cont;           // Mostramos dato enviado en PORTA
            cont--;                 // Actualizamos valor del contador
        }*/
        //SERVO_1(POT1);
        PIR1bits.SSPIF = 0;         // Limpiamos bandera de interrupci n�
    }
}

void main(void) {
    setup();
    while(1){
        
        if(old_dato != dato){
            check = dato & 0x01;
            if(check == READ){
                POT1=dato>>1;
                SERVO_1(POT1);
            }else if(check == WRITE){
                POT2=dato>>1;
                SERVO_2(POT2);
            }
            old_dato = dato;
        }
        
    }
    return;
}

void setup(){
    
    ANSEL = 0x00;
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
 
    PORTC = 0x00;
    TRISC = 0b00011000;       // SCL and SDA as input
    
    //Configuracion PWM
    TRISCbits.TRISC2 = 1;       //Deshabilitar salida CCP1
    TRISCbits.TRISC1 = 1;       //Deshabilitar salida CCP2
    PR2 = 31;                  //periodo 2ms
    
    //Configuracion CCP
    CCP1CON = 0;                //Apagamos CCP1
    CCP2CON = 0;                //Apagamos CCP2
    CCP1CONbits.P1M = 0;        //modo single output
    CCP1CONbits.CCP1M = 0b1100; //PWM CCP1
    CCP2CONbits.CCP2M = 0b1100; //PWM CCP2
    
    CCPR1L = 32>>2;
    CCP1CONbits.DC1B = 32 & 0b11; //0.5ms ancho de pulso, 25% duty cycle
    
    CCPR2L = 32>>2;
    CCP2CONbits.DC2B0 = 32 & 0b01; //0.5ms ancho de pulso, 25% duty cycle
    CCP2CONbits.DC2B1 = (32 & 0b10)>>1;
    
    PIR1bits.TMR2IF = 0;        //bandera TMR2
    T2CONbits.T2CKPS = 0b11;    //prescaler 1:16
    T2CONbits.TMR2ON = 1;       //encender TMR2
    while(!PIR1bits.TMR2IF);
    PIR1bits.TMR2IF = 0;        //Esperar ciclo TMR2
    
    TRISCbits.TRISC2 = 0;       //Habilitar salida CCP1
    TRISCbits.TRISC1 = 0;       //Habilitar salida CCP2
    
    //Configuracion I2C esclavo
    SSPADD = 0x10;              // Direcci n de esclavo: 0x08 
    SSPSTATbits.SMP = 1;        // Velocidad de rotacion
    SSPCONbits.SSPM = 0b0110;   // I2C slave mode, 7-bit address
    SSPCONbits.SSPEN = 1;       // Habilitamos pines de I2C
    
    //Configuraciones de interrupcioens
    PIR1bits.SSPIF = 0;         // Limpiamos bandera de interrupci n de I2C�
    PIE1bits.SSPIE = 1;         // Habilitamos interrupcion de I2C
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales
    return;
}

void SERVO_1(uint8_t val){
    CCP1 = map(val, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); //mapeamos valor de potenciometro
    CCPR1L = (uint8_t)(CCP1>>2);    
    CCP1CONbits.DC1B = CCP1 & 0b11; 
    //__delay_ms(10);
}

void SERVO_2(uint8_t val){
    CCP2 = map(val, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); 
    CCPR2L = (uint8_t)(CCP2>>2);    
    CCP2CONbits.DC2B0 = CCP2 & 0b01;
    CCP2CONbits.DC2B1 = CCP2 & 0b10;
    //__delay_ms(10);
}

// y = y0 + [(y1 - y0)/(x1-x0)]*(x-x0)
unsigned short map(uint8_t x, uint8_t x0, uint8_t x1, 
            unsigned short y0, unsigned short y1){
    return (unsigned short)(y0+((float)(y1-y0)/(x1-x0))*(x-x0));
}
