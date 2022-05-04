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

//void USART_Tx(char data);
//void USART_Cadena(char *str);

const char tabla[] = {'H','o','l','a',' '};
char string = 0;
uint8_t unidad, decena, centena;
uint8_t indice, pot;
void Print(char *str);
void TX(char dato);

void __interrupt() isr (void){
    /*if(PIR1bits.RCIF)          
        indice = RCREG;
        //USART_Cadena(" Hello fck wrld \r");
    else*/ if(PIR1bits.ADIF){
        if(ADCON0bits.CHS == 0)     //utilizamos 2 canales donde cada uno tiene 
            pot = ADRESH;         //un potenciometro de 1k, dependiendo de cual canal
        PIR1bits.ADIF = 0;    
    }
    
    
    
    return;
}
    
void main(void) {
    setup();
    
    while(1){
        if(ADCON0bits.GO == 0){             // No hay proceso de conversion
            ADCON0bits.GO = 1;              // Iniciamos proceso de conversi n�
        }
        PORTB = pot;
        /*centena = pot/100;                            
        decena = (pot - (100 * centena))/10;         
        unidad = pot - (100 * centena)-(10 * decena);
        
        centena += 48;
        decena += 48;
        unidad += 48;
        
        Print("1. Leer Potenciometro\r");
        Print("2. Enviar Ascii\r");
        
        while(PIR1bits.RCIF == 0);
        switch(indice){
            case('1'):
                TX(centena);
                TX(decena);
                TX(unidad);
                Print("\rListo\r");
                break;
                
            case('2'):
                Print("Ingresa un dato\r");
                while(PIR1bits.RCIF);          
                PORTD = RCREG;
                Print("Listo\r");
                break;
        }*/
        
        //indice = 0;
        //__delay_ms(1000);
        /*while(indice <= 6){
            
            if(PIR1bits.TXIF){
                TXREG = tabla[indice];
                ++indice;
            }
        }*/
        //Print();
        //TXREG = 'Hola';
    }
    return;
}

void setup(void){
    
    ANSEL =0b00000001;      //AN0 AN1 AN2
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00000001;     //RA1 y RA0 RA2
    TRISD = 0x00;
    PORTD = 0x00;
    PORTA = 0x00;
    TRISB =0x00;
    PORTB = 0x00;
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
    //PIE1bits.RCIE = 1;          // Habilitamos Interrupciones de recepción
    
    return;
}

void Print(char *str){
        while(*str != '\0'){
            TX(*str);
            str++;
        }
}

void TX(char dato){
    
    while(TXSTAbits.TRMT==0);
        TXREG = dato;
}

/*
void USART_Cadena(char *str){
        while(*str != '\0'){
            USART_Tx(*str);
            str++;
        }
}
    
void USART_Tx(char data){
        while(TXSTAbits.TRMT == 0);
        TXREG = data;
    }*/