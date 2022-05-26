/*
 * File:   main_M.c
 * Author: HP
 *
 * Created on 24 de mayo de 2022, 06:51 PM
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
#define I2C_SPEED 100000
#define ADDRESS_1 0x08      //slave 0x10
#define ADDRESS_2 0x09      //slave 0x12
#define READ 0b0
#define WRITE 0b1
#include <xc.h>
#include <stdint.h>

uint8_t modo, POT1,POT2,POT3,POT4, data;

void setup(void);

void wait_I2C(void);
void start_I2C(void);
void restart_I2C(void);
void stop_I2C(void);
void send_ACK(void);
void send_NACK(void);
__bit write_I2C(uint8_t data);
uint8_t read_I2C(void);

uint8_t read_EEPROM(uint8_t address);
void write_EEPROM(uint8_t address, uint8_t data);

void __interrupt() isr (void){
    if(INTCONbits.RBIF){
        if (!PORTBbits.RB0)               //si presiona el boton, guardamos en
            ++modo;
        if(modo>=2)
            modo=0;
        
        if(modo==0){
            PORTEbits.RE0 = 1;
            PORTEbits.RE1 = 0;
            PORTEbits.RE2 = 0;
            
            if(!PORTBbits.RB1){
                write_EEPROM(0x01,POT1);
                write_EEPROM(0x02,POT2);
                write_EEPROM(0x03,POT3);
                write_EEPROM(0x04,POT4);
            }
            if(!PORTBbits.RB2){
                write_EEPROM(0x05,POT1);
                write_EEPROM(0x06,POT2);
                write_EEPROM(0x07,POT3);
                write_EEPROM(0x08,POT4);
            }    
        
        }else if(modo==1){
            PORTEbits.RE0 = 0;
            PORTEbits.RE1 = 1;
            PORTEbits.RE2 = 0;
            
            if(!PORTBbits.RB1){
                POT1 =  read_EEPROM(0x01);
                POT2 =  read_EEPROM(0x02);
                POT3 =  read_EEPROM(0x03);
                POT4 =  read_EEPROM(0x04);
            }
            if(!PORTBbits.RB2){
                POT1 =  read_EEPROM(0x05);
                POT2 =  read_EEPROM(0x06);
                POT3 =  read_EEPROM(0x07);
                POT4 =  read_EEPROM(0x08);
            }    
        }
        INTCONbits.RBIF = 0;
        
    }
    else if(PIR1bits.ADIF){
        if(modo==0){
            if(ADCON0bits.CHS == 0){   
                POT1 = ADRESH;
            }else if(ADCON0bits.CHS == 1){
                POT2 = ADRESH;
            }else if(ADCON0bits.CHS == 2){
                POT3 = ADRESH;
            }else if(ADCON0bits.CHS == 3){
                POT4 = ADRESH;
            }
        }
        PIR1bits.ADIF = 0;
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
                ADCON0bits.CHS = 0b0011;
            else if(ADCON0bits.CHS == 0b0011)
                ADCON0bits.CHS = 0b0000;
            __delay_us(40);
            ADCON0bits.GO = 1;
        }
        
        data = (uint8_t)((ADDRESS_1<<1)+READ);
        start_I2C();                // Iniciamos comunicaci n�
        write_I2C(data);          // Enviamos direcci n de esclavo a recibir datos�
        write_I2C(POT1);            // Enviamos dato al esclavo
        stop_I2C();                 // Actualizamos valor a enviar
        __delay_ms(10);
        
    }
    return;
}

void setup(){
    
    ANSEL =0b00001111;      //AN0 AN1 AN2
    ANSELH = 0x00;
    
    OSCCONbits.IRCF = 0b0100;   //1MHz
    OSCCONbits.SCS = 1;
    
    TRISA = 0b00001111;     //RA0 RA1 RA2 RA3
    PORTA = 0x00;
    
    PORTC = 0x00;
    TRISC = 0b00011000;
    //TRISCbits.TRISC3 = 1;
    //TRISCbits.TRISC4 = 1;       // SCL and SDA as input
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
    
    //Configuracion push button
    TRISBbits.TRISB0 = 1;       //RB0 como entrada
    TRISBbits.TRISB1 = 1;
    TRISBbits.TRISB2 = 1;
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB = 0x07;       //0001 RB0
    IOCBbits.IOCB = 0x07;       //RB0 pull ups eh interrupciones
    
    //Configuracion I2C maestro
    SSPADD = ((_XTAL_FREQ)/(4*I2C_SPEED)) - 1;  // 100 kHz
    SSPSTATbits.SMP = 1;        // Velocidad de rotacion
    SSPCONbits.SSPM = 0b1000;   // I2C master mode, clock= Fosc/(4*(SSPADD+1))
    SSPCONbits.SSPEN = 1;       // Habilitamos pines de I2C
    PIR1bits.SSPIF = 0;         // Limpiamos bandera de interrupcion de I2C
    
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
    __delay_ms(10);
    EECON1bits.WREN=0;      //desabilitar estritura
    INTCONbits.RBIF=0;      //habilitar interrupciones
    INTCONbits.GIE=1;
}

void wait_I2C(void){
    while(!PIR1bits.SSPIF);     // Esperamos a que se ejecute instruccion de I2C
    PIR1bits.SSPIF = 0;         // Limpimos bandera
}
void start_I2C(void){
    SSPCON2bits.SEN = 1;        // Inicializar comunicaci n�
    wait_I2C();
}
void restart_I2C(void){
    SSPCON2bits.RSEN = 1;       // Reiniciar de comunicaci n�
    wait_I2C();
}
void stop_I2C(void){
    SSPCON2bits.PEN = 1;        // Finalizar comunicaci n�
    wait_I2C();
}
void send_ACK(void){
    SSPCON2bits.ACKDT = 0;      // Confirmar que se recibi  la data�
    SSPCON2bits.ACKEN = 1;      // Envio de ack al esclavo
    wait_I2C();
}
void send_NACK(void){
    SSPCON2bits.ACKDT = 1;      // Confirmar recepci n al finalizar comunicaci n��
    SSPCON2bits.ACKEN = 1;      // Envio de nack al esclavo
    wait_I2C();
}
__bit write_I2C(uint8_t data){
    SSPBUF = data;              // Cargar dato a enviar en el buffer
    wait_I2C();
    return ACKSTAT;             // Obtener ACK del esclavo
}
uint8_t read_I2C(void){
    SSPCON2bits.RCEN = 1;       // Pedir dato al esclavo  
    wait_I2C();
    return SSPBUF;              // Regresar dato recibido
}