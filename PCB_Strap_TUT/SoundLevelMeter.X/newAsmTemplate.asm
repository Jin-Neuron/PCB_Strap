    PROCESSOR 16F1503
#include <xc.inc>

; CONFIG1
    CONFIG  FOSC = INTOSC         ; Oscillator Selection Bits (INTOSC oscillator: I/O function on CLKIN pin)
    CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
    CONFIG  PWRTE = ON            ; Power-up Timer Enable (PWRT enabled)
    CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
    CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
    CONFIG  BOREN = ON            ; Brown-out Reset Enable (Brown-out Reset enabled)
    CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)

; CONFIG2
    CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
    CONFIG  STVREN = OFF          ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will not cause a Reset)
    CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
    CONFIG  LPBOR = OFF           ; Low-Power Brown Out Reset (Low-Power BOR is disabled)
    CONFIG  LVP = OFF             ; Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

    Pins_A	equ  0x70
    Pins_C	equ  0x71
    COUNT	equ  0x72
    Flags	equ  0x73
    count_1	equ  0x74
    count_2	equ  0x75
    MicLevelMix	equ  0x76
	
    PSECT Por_Vec,class=CODE,delta=2

START:	
	BANKSEL	OSCCON
	MOVLW	01111000B  ; Set Clock 
	MOVWF	OSCCON
	
	BANKSEL	PORTA
	CLRF	PORTA	    ; Init PORTA
	BANKSEL PORTC
	CLRF	PORTC	    ; Init PORTC
	
	BANKSEL	LATA
	CLRF	LATA	    ; DataA Latch
	BANKSEL LATC
	CLRF	LATC	    ; DataC Latch
	
	BANKSEL	ANSELA
	MOVLW	00000100B ; RA2 as Analog Input
	MOVWF	ANSELA
	BANKSEL ANSELC
	CLRF	ANSELC	    ; All digital I/O
	
	BANKSEL ADCON1
	MOVLW	11000000B
	MOVWF	ADCON1
	
	BANKSEL	TRISA
	MOVLW	11001011B ; RA5,4 : Digital I/O / RA2 : Analog Input
	MOVWF	TRISA
	BANKSEL	TRISC
	MOVLW	11000000B ; RC5-0 : Digital I/O
	MOVWF	TRISC
	
	BANKSEL ADCON0
	MOVLW	00001001B ; Set AN2
	MOVWF	ADCON0
	
	BANKSEL	COUNT
	CLRF	COUNT
	CLRF	Flags
	MOVLW	0xFF
	MOVWF	COUNT
	
		
STEP1:	
	BANKSEL	ADCON0
	BSF	ADCON0,1
	BTFSC	ADCON0,1
	GOTO	$-1	    ; Wait ADC Completing
	
	BANKSEL	ADRESL
	MOVF	ADRESL,W
	ANDLW	0xF0
	MOVWF	MicLevelMix
	BANKSEL	ADRESH
	MOVF	ADRESH,W
	ANDLW	0x03
	IORWF	MicLevelMix,F
	SWAPF	MicLevelMix,F
	
	BANKSEL	MicLevelMix
	MOVLW   0x03
	SUBWF   MicLevelMix,W
	BANKSEL	LATA
	BTFSC   STATUS,0
	goto	SetA4
	bcf	LATA, 4
	goto	CheckA5
	
    SetA4:
	bsf	LATA, 4
	
    CheckA5:
	
	BANKSEL	MicLevelMix
	MOVLW   0x05
	SUBWF   MicLevelMix,W
	BANKSEL	LATA
	BTFSC   STATUS,0
	goto	SetA5
	bcf	LATA, 5
	goto	CheckC0
	
    SetA5:
	bsf	LATA, 5
	
    CheckC0:
    
	BANKSEL	MicLevelMix
    	MOVLW   0x07
	SUBWF   MicLevelMix,W
	BANKSEL	LATC
	BTFSC   STATUS,0
	goto	SetC0
	bcf	LATC, 0
	goto	CheckC1
	
    SetC0:
	bsf	LATC, 0
	
    CheckC1:
	
	BANKSEL	MicLevelMix
	MOVLW   0x09
	SUBWF   MicLevelMix,W
	BANKSEL	LATC
	BTFSC   STATUS,0
	goto	SetC1
	bcf	LATC, 1
	goto	CheckC2
	
    SetC1:
	bsf	LATC, 1
	
    CheckC2:
	
	BANKSEL	MicLevelMix
	MOVLW   0x0B
	SUBWF   MicLevelMix,W
	BANKSEL	LATC
	BTFSC   STATUS,0
	goto	SetC2
	bcf	LATC, 2
	goto	CheckC3
	
    SetC2:
	bsf	LATC, 2
	
    CheckC3:
	
	BANKSEL	MicLevelMix
	MOVLW   0x0D
	SUBWF   MicLevelMix,W
	BANKSEL	LATC
	BTFSC   STATUS,0
	goto	SetC3
	bcf	LATC, 3
	goto	CheckC4
	
    SetC3:
	bsf	LATC, 3
	
    CheckC4:
	
	BANKSEL	MicLevelMix
	MOVLW   0x0F
	SUBWF   MicLevelMix,W
	BANKSEL	LATC
	BTFSC   STATUS,0
	goto	SetC4
	bcf	LATC, 4
	goto	CheckC5
	
    SetC4:
	bsf	LATC, 4
	
    CheckC5:
	
	BANKSEL	MicLevelMix
	MOVLW   0x11
	SUBWF   MicLevelMix,W
	BANKSEL	LATC
	BTFSC   STATUS,0
	goto	SetC5
	bcf	LATC, 5
	goto	endLoop
	
    SetC5:
	bsf	LATC, 5
    
    endLoop:
	
	CALL	Count64k
	
	GOTO	STEP1
	
; ???? 256 x 256 (789 ms)
Count64k:
	BANKSEL	count_1
	MOVLW	0xFF
	MOVWF	count_1
	MOVLW	0xFF
	MOVWF   count_2
Count64kLoop:
	decfsz  count_1,F
	bra     Count64kLoop
	decfsz  count_2,F
	bra     Count64kLoop
	return
	END