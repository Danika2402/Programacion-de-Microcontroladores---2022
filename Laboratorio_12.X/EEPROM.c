/*
 * File:   EEPROM.c
 * Author: HP
 *
 * Created on 16 de mayo de 2022, 10:53 AM
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
uint8_t cont;

uint8_t read_EEPROM(uint8_t address);
void write_EEPROM(uint8_t address, uint8_t data);

void __interrupt() isr (void){
    if(PIR1bits.ADIF){
        if(ADCON0bits.CHS == 0)     //utilizamos 1 canal 
            PORTC = ADRESH;         //guardamos en PORTC
        PIR1bits.ADIF = 0;    
    }
    else if(INTCONbits.RBIF){        
        if (!PORTBbits.RB0)               //si presiona el boton, guardamos en
            write_EEPROM(0x05,PORTC);     //EEPROM el valor del PORTC, en una direccion
        INTCONbits.RBIF = 0;
    }
    return;
}

void main(void) {
    setup();
    while(1){
        if(ADCON0bits.GO == 0)      //Solo usamos un canal          
            ADCON0bits.GO = 1; 
        PORTD = read_EEPROM(0x05);  //mostramos en el PORTD el dato guardado en 
    }                               //el EEPROM en la direccion
    return;
}

void setup (void){
    ANSELH = 0x00;
    ANSEL =0b00000001;      //AN0
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00000001;     //RA0 potenciometro
    PORTA = 0x00;
    PORTD = 0x00;
    TRISD = 0x00;
    TRISC = 0x00;
    PORTC = 0x00;
              
    //Configuraciones de ADC
    ADCON0bits.ADCS = 0b00;     // Fosc/2
    
    ADCON1bits.VCFG0 = 0;       //VDD *Referencias internas
    ADCON1bits.VCFG1 = 1;       //VSS
    
    ADCON0bits.CHS = 0b0000;    //canal AN0
    ADCON1bits.ADFM = 0;        //justificacion Izquierda
    ADCON0bits.ADON = 1;        //habilitar modulo ADC
    __delay_us(40);
    
    //Configuracion push button
    TRISBbits.TRISB0 = 1;       //RB0 como entrada
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB = 0x01;       //0001 RB0
    IOCBbits.IOCB = 0x01;       //RB0 pull ups eh interrupciones
    
    //Configuraciones de interrupcioens
    INTCONbits.RBIE = 1;        //interrupciones en PORTB y TMR0
    INTCONbits.RBIF = 0;        //Apagamos banderas
    PIR1bits.ADIF = 0;          //bandera int. ADC
    PIE1bits.ADIE = 1;          //habilitar int. ADC
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales
    return;
}

uint8_t read_EEPROM(uint8_t address){
    EEADR = address;
    EECON1bits.EEPGD = 0;   //Lectura al EEPROM
    EECON1bits.RD = 1;      //Obtener dato
    return EEDAT;           //lo regresamos
}
void write_EEPROM(uint8_t address, uint8_t data){
    EEADR = address;        
    EEDAT = data;
    EECON1bits.EEPGD = 0;   //Escritura al EEPROM
    EECON1bits.WREN=1;      //habilitar escritura
    
    INTCONbits.GIE=0;       
    EECON2 = 0x55;
    EECON2=0xaa;
    
    EECON1bits.WR=1;        //iniciar escritura
    
    EECON1bits.WREN=0;      //desabilitar estritura
    INTCONbits.RBIF=0;      //habilitar interrupciones
    INTCONbits.GIE=1;
}
