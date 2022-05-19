/*
 * File:   main.c
 * Author: HP
 *
 * Created on 17 de mayo de 2022, 09:51 PM
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

uint8_t modo;

void setup(void);
unsigned short map(uint8_t val, uint8_t in_min, uint8_t in_max, 
            unsigned short out_min, unsigned short out_max);
uint8_t read_EEPROM(uint8_t address);
void write_EEPROM(uint8_t address, uint8_t data);

#define IN_MIN 0                // Valor minimo de entrada del potenciometro
#define IN_MAX 255              // Valor maximo de entrada del potenciometro
#define OUT_MIN 62              // Valor minimo de ancho de pulso de señal PWM
#define OUT_MAX 125             // Valor maximo de ancho de pulso de señal PWM

unsigned short CCP1,CCP2, pot3,pot;            // Variable para almacenar ancho de pulso al hacer la interpolaci lineal

void __interrupt() isr (void){
    if(INTCONbits.RBIF){
        if(modo==4)
            modo=0;
        
        if (!PORTBbits.RB0)               //si presiona el boton, guardamos en
            ++modo;
        INTCONbits.RBIF = 0;
    }
    
    else if(modo==0){
        PORTE=1;
        if(INTCONbits.RBIF){
            if(!PORTBbits.RB1)
            ++PORTD;
        INTCONbits.RBIF = 0;
        }
    }else if(modo==1){
        PORTE=2;
        if(INTCONbits.RBIF){
            if(!PORTBbits.RB1)
            --PORTD;
        INTCONbits.RBIF = 0;
        }
    }else if(modo==3){
        PORTE=4;
        if(PIR1bits.ADIF){
            if(ADCON0bits.CHS == 0)     //utilizamos 2 canales donde cada uno tiene 
                PORTD = ADRESH;         //un potenciometro de 1k, dependiendo de cual canal
        PIR1bits.ADIF = 0;
        }
    }
    
    /*if(PIR1bits.ADIF){
        if(ADCON0bits.CHS == 0){            
            CCP1 = map(ADRESH, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); //mapeamos valor de potenciometro
            CCPR1L = (uint8_t)(CCP1>>2);    
            CCP1CONbits.DC1B = CCP1 & 0b11; 
        }else if(ADCON0bits.CHS == 1){
            CCP2 = map(ADRESH, IN_MIN, IN_MAX, OUT_MIN, OUT_MAX); 
            CCPR2L = (uint8_t)(CCP2>>2);    
            CCP2CONbits.DC2B0 = CCP2 & 0b01;
            CCP2CONbits.DC2B1 = CCP2 & 0b10;
        }
        PIR1bits.ADIF = 0;
    }else if(INTCONbits.RBIF){        
        if (!PORTBbits.RB0)               //si presiona el boton, guardamos en
            ++PORTD;
            //write_EEPROM(0x05,PORTC);     //EEPROM el valor del PORTC, en una direccion
        else if(!PORTBbits.RB1)
            --PORTD;
        INTCONbits.RBIF = 0;
    }*/
    if(modo==0){
        TRISEbits.TRISE0 = 1;       //Deshabilitar salida CCP1
        TRISEbits.TRISE1 = 0;
        TRISEbits.TRISE2 = 0;
    }else if(modo==1){
        TRISEbits.TRISE0 = 0;       //Deshabilitar salida CCP1
        TRISEbits.TRISE1 = 1;
        TRISEbits.TRISE2 = 0;
        
    }else if(modo==3){
        TRISEbits.TRISE0 = 0;       //Deshabilitar salida CCP1
        TRISEbits.TRISE1 = 0;
        TRISEbits.TRISE2 = 1;
    }
    return;
}

void main(void) {
    setup();
    while(1){
        /*if(ADCON0bits.GO == 0){
            if(ADCON0bits.CHS == 0b0000)        //cambianos de un canal al otro
                ADCON0bits.CHS = 0b0001;        //siempre con un delay 
            else if(ADCON0bits.CHS == 0b0001)
                ADCON0bits.CHS = 0b0000;
            __delay_us(40);
            ADCON0bits.GO = 1;
        }*/
        if(ADCON0bits.GO == 0)      //Solo usamos un canal          
            ADCON0bits.GO = 1; 
    }
    return;
}

void setup(void){
    
    ANSEL =0b00000011;      //AN0 AN1 AN2
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00000011;     //RA1 y RA0
    PORTA = 0x00;
    
    PORTC = 0x00;
    TRISC = 0x00;
    PORTD = 0x00;
    TRISD = 0x00;
    TRISE = 0x00;
    PORTE = 0x00;
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
    
    //Configuracion push button
    TRISBbits.TRISB0 = 1;       //RB0 como entrada
    TRISBbits.TRISB1 = 1;
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB = 0x03;       //0001 RB0
    IOCBbits.IOCB = 0x03;       //RB0 pull ups eh interrupciones
    
    //Configuraciones de interrupcioens
    INTCONbits.RBIE = 1;        //interrupciones en PORTB y TMR0
    INTCONbits.RBIF = 0;        //Apagamos banderas
    PIR1bits.ADIF = 0;          //bandera int. ADC
    PIE1bits.ADIE = 1;          //habilitar int. ADC
    INTCONbits.PEIE = 1;        //habilitar int. perifericos
    INTCONbits.GIE = 1;         //habilitar int. globales
    return;
}
// y = y0 + [(y1 - y0)/(x1-x0)]*(x-x0)

unsigned short map(uint8_t x, uint8_t x0, uint8_t x1, 
            unsigned short y0, unsigned short y1){
    return (unsigned short)(y0+((float)(y1-y0)/(x1-x0))*(x-x0));
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
    __delay_ms(10);
    EECON1bits.WREN=0;      //desabilitar estritura
    INTCONbits.RBIF=0;      //habilitar interrupciones
    INTCONbits.GIE=1;
}
