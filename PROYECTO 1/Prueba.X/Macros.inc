#include <xc.inc>
    
RESET_TMR0 MACRO 
    banksel TMR0	//2ms
    movlw   254
    movwf   TMR0
    bcf	    T0IF
    ENDM
    
RESET_TMR1 MACRO	    //1s , 85EE = 34286	
    movlw   0x85	    //0XF9   
    movwf   TMR1H	    
    movlw   0xEE	    //0X0D    
    movwf   TMR1L	    
    bcf	    TMR1IF	     
    ENDM



