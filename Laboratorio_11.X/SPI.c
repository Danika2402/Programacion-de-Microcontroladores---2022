/*
 * File:   SPI.c
 * Author: HP
 *
 * Created on 9 de mayo de 2022, 12:11 AM
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
#define FLAG_SPI 0xFF

#include <xc.h>
#include <stdint.h>
void setup(void);
uint8_t cont_slave,pot_master;

char valor_temp;

void __interrupt() isr (void){
    if (PORTAbits.RA0){
        if(PIR1bits.ADIF){     //ADC en RA0 donde guardamos el valor del potenciometro
            if(ADCON0bits.CHS == 2)     //en una variable
                PORTD = ADRESH;        
        PIR1bits.ADIF = 0;
        }
    }else if(!PORTAbits.RA0){
        if(INTCONbits.RBIF){        //Chequear si se prendio la bandera
            if (!PORTBbits.RB0)     //Si RB0 = 0, incrementar PORTA             
                ++PORTD;            
            if(!PORTBbits.RB1)      //Si RB1 = 0, decrementar PORTA
                --PORTD;
        INTCONbits.RBIF = 0;    // Limpiamos bandera 
        }
    
    }/*
    else if (PIR1bits.SSPIF){
        valor_temp = SSPBUF;
        if (valor_temp != FLAG_SPI){
            PORTD = valor_temp; 
            SSPBUF = cont_slave;
        }
        PIR1bits.SSPIF = 0;
    }*/
}

void main(void) {
    setup();
    while(1){
        if(PORTAbits.RA0){
            if(ADCON0bits.GO == 0){    //Solo usamos un canal          
                ADCON0bits.GO = 1;              
            }
        }
        /*if(PORTAbits.RA0){
            SSPBUF = pot_master;
            while(!SSPSTATbits.BF){}
            PORTD = pot_master;
            PORTAbits.RA7 = 1;      
            __delay_ms(10);
            PORTAbits.RA7 = 0;
            
            SSPBUF = FLAG_SPI;
            while(!SSPSTATbits.BF){}
            PORTD = SSPBUF;         
            __delay_ms(1000);
        }*/
    }
    return;
}

void setup(void){
    ANSELH = 0x00;
    
    TRISA = 0b00100101;
    PORTA = 0X00;
    TRISD = 0x00;
    PORTD = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    //__delay_ms(1000);
    
    /*if(PORTAbits.RA0)*/{
        ANSEL =0b00000100;      //AN2
        
        TRISC = 0b00010000;         // -> SDI entrada, SCK y SD0 como salida
        PORTC = 0x00;
        //SSPCON 
        /*SSPCONbits.SSPM = 0b0000;   // -> SPI Maestro, Reloj -> Fosc/4 (250kbits/s)
        SSPCONbits.CKP = 0;         // -> Reloj inactivo en 0
        SSPCONbits.SSPEN = 1;       // -> Habilitamos pines de SPI
        // SSPSTAT
        SSPSTATbits.CKE = 1;        // -> Dato enviado cada flanco de subida
        SSPSTATbits.SMP = 1;        // -> Dato al final del pulso de reloj
        SSPBUF = pot_master;        // Enviamos un dato inicial
       */
        //Configuraciones de ADC
        ADCON0bits.ADCS = 0b00;     // Fosc/2

        ADCON1bits.VCFG0 = 0;       //VDD *Referencias internas
        ADCON1bits.VCFG1 = 0;       //VSS

        ADCON0bits.CHS = 0b0010;    //canal AN0
        ADCON1bits.ADFM = 0;        //justificacion Izquierda
        ADCON0bits.ADON = 1;        //habilitar modulo ADC
        __delay_us(40);
        
        //Configuraciones de interrupcioens
        PIR1bits.ADIF = 0;          //bandera int. ADC
        PIE1bits.ADIE = 1;          //habilitar int. ADC
        INTCONbits.PEIE = 1;        //habilitar int. perifericos
        INTCONbits.GIE = 1;         //habilitar int. globales

    }/*else{
        ANSEL =0x00;      
        TRISC = 0b00011000; // -> SDI y SCK entradas, SD0 como salida
        PORTC = 0x00;
        
        // SSPCON <5:0>
        SSPCONbits.SSPM = 0b0100;   // -> SPI Esclavo, SS hablitado
        SSPCONbits.CKP = 0;         // -> Reloj inactivo en 0
        SSPCONbits.SSPEN = 1;       // -> Habilitamos pines de SPI
        // SSPSTAT<7:6>
        SSPSTATbits.CKE = 1;        // -> Dato enviado cada flanco de subida
        SSPSTATbits.SMP = 0;        // -> Dato al final del pulso de reloj
        
        //Configuracion push button
        TRISBbits.TRISB0 = 1;       //RB0 y RB1 como entrada
        TRISBbits.TRISB1 = 1;
        OPTION_REGbits.nRBPU = 0;
        WPUBbits.WPUB = 0x03;       //0011 RB0 y RB1
        IOCBbits.IOCB = 0x03;       //RB0 y RB1 pull ups eh interrupciones

        //configuracion interrupciones
        INTCONbits.RBIE = 1;        //interrupciones en PORTB y TMR0
        INTCONbits.RBIF = 0;        //Apagamos banderas
        //PIR1bits.SSPIF = 0;         // Limpiamos bandera de SPI
        //PIE1bits.SSPIE = 1;         // Habilitamos int. de SPI
        INTCONbits.PEIE = 1;        //habilitar int. perifericos
        INTCONbits.GIE = 1;         //habilitar int. globales
    
    }*/
    
}
