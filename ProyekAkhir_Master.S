#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main

;=======================================================================
main:
    SBI   DDRC, 0          ; Set pin PC0 as input for ADC0
    LDI   R20, 0xC0        ; Internal 2.56V, right-justified data, ADC0
    STS   ADMUX, R20
    LDI   R20, 0x87        ; Enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R20
    SBI   DDRB, 0          ; Set pin PB0 as output

    LDI   R23, (1<<INT0)   ; Load INT0 bit into R23
    OUT   EIMSK, R23       ; Output R23 to EIMSK register
    LDI   R23, (1<<ISC01)  ; Load ISC01 bit into R23
    STS   EICRA, R23       ; Store R23 into EICRA register

    SEI                    ; Enable global interrupts

    LDI   R21, 1<<TWPS0    ; Set prescaler to 1
    STS   TWSR, R21        ; Store R21 into TWSR register
    LDI   R21, 12          ; Load 12 into R21 (division factor for SCK freq = 400kHz)
    STS   TWBR, R21        ; Store R21 into TWBR register
    LDI   R21, (1<<TWEN)   ; Load TWEN flag into R21
    STS   TWCR, R21        ; Store R21 into TWCR register

    CLR   R25              ; Initialize temperature register

loop:
    RCALL read_LDR         ; Read data from LDR
    RCALL read_DHT11       ; Read data from DHT11
    RCALL send_data        ; Send data to slave via I2C
    RJMP loop              ; Repeat the loop

;=======================================================================
read_LDR:
    LDI   R20, 0xC7        ; Set ADSC in ADCSRA to start conversion
    STS   ADCSRA, R20
wait_ADC:
    LDS   R21, ADCSRA      ; Check ADIF flag in ADCSRA
    SBRS  R21, 4           ; Skip jump when conversion is done (flag set)
    RJMP  wait_ADC         ; Loop until ADIF flag is set
    LDI   R17, 0xD7        ; Set ADIF flag again
    STS   ADCSRA, R17      ; So that controller clears ADIF
    LDS   R18, ADCL        ; Get low-byte result from ADCL
    LDS   R19, ADCH        ; Get high-byte result from ADCH
    RET

read_DHT11:
    SBI   DDRB, 1          ; Set bit 1 of DDRB (PB1 configured as output)
    CBI   PORTB, 1         ; Clear bit 1 of PORTB (PB1 set low)
    RCALL delay_20ms       ; Call delay_20ms subroutine
    SBI   PORTB, 1         ; Set bit 1 of PORTB (PB1 set high)
    CBI   DDRB, 1          ; Clear bit 1 of DDRB (PB1 configured as input)

w1:
    SBIC  PINB, 1          ; Skip next instruction if bit 1 of PINB is clear
    RJMP  w1               ; Jump to w1 (Wait for DHT11 low pulse)
w2:
    SBIS  PINB, 1          ; Skip next instruction if bit 1 of PINB is set
    RJMP  w2               ; Jump to w2 (Wait for DHT11 high pulse)
w3:
    SBIC  PINB, 1          ; Skip next instruction if bit 1 of PINB is clear
    RJMP  w3               ; Jump to w3 (Wait for DHT11 low pulse)

    RCALL DHT11_reading    ; Read humidity (1st byte)
    RCALL DHT11_reading    ; Read humidity (2nd byte)
    RCALL DHT11_reading    ; Read temperature (3rd byte)

    RET

send_data:
    RCALL I2C_start        ; Call I2C_start subroutine
    LDI   R27, 0b10010000  ; Load 0b10010000 into R27
    RCALL I2C_write        ; Call I2C_write subroutine
    MOV   R27, R18         ; Move low byte of LDR data to R27
    RCALL I2C_write        ; Call I2C_write subroutine
    MOV   R27, R19         ; Move high byte of LDR data to R27
    RCALL I2C_write        ; Call I2C_write subroutine
    MOV   R27, R25         ; Move DHT11 data to R27
    RCALL I2C_write        ; Call I2C_write subroutine
    RCALL I2C_stop         ; Call I2C_stop subroutine
    RET

I2C_start:
    LDI   R21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN) ; Load TWINT, TWSTA, and TWEN flags into R21
    STS   TWCR, R21        ; Store R21 into TWCR register
wt1:
    LDS   R21, TWCR        ; Load value from TWCR register into R21
    SBRS  R21, TWINT       ; Skip next instruction if TWINT flag is set
    RJMP  wt1              ; Jump to wt1 (Wait for end of transmission)
    RET

I2C_write:
    STS   TWDR, R27        ; Store R27 into TWDR register
    LDI   R21, (1<<TWINT)|(1<<TWEN) ; Load TWINT and TWEN flags into R21
    STS   TWCR, R21        ; Store R21 into TWCR register
wt2:
    LDS   R21, TWCR        ; Load value from TWCR register into R21
    SBRS  R21, TWINT       ; Skip next instruction if TWINT flag is set
    RJMP  wt2              ; Jump to wt2 (Wait for end of transmission)
    RET

I2C_stop:
    LDI   R21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN) ; Load TWINT, TWSTO, and TWEN flags into R21
    STS   TWCR, R21        ; Store R21 into TWCR register
    RET

DHT11_reading:
    LDI   R24, 8           ; Load 8 into R24
    CLR   R25              ; Clear data register
w4:
    SBIS  PINB, 1          ; Skip next instruction if bit 1 of PINB is set
    RJMP  w4               ; Jump to w4 (Detect data bit - high pulse)
    RCALL delay_timer0     ; Call delay_timer0 subroutine (Wait 50us)
    SBIS  PINB, 1          ; Skip next instruction if bit 1 of PINB is set
    RJMP  skp              ; Jump to skp
    SEC                    ; Set carry flag (C=1)
    ROL   R25              ; Rotate left through carry - Shift in 1 into LSB data register
    RJMP  w5               ; Jump to w5 (Wait for low pulse)
skp:
    LSL   R25              ; Logical shift left - Shift in 0 into LSB data register
w5:
    SBIC  PINB, 1          ; Skip next instruction if bit 1 of PINB is clear
    RJMP  w5               ; Jump to w5 (Wait for DHT11 low pulse)
    DEC   R24              ; Decrement R24
    BRNE  w4               ; Branch if not equal to w4 (Go back & detect next bit)
    RET

;=======================================================================

; Delay subroutines
delay_20ms:                ; Define delay_20ms subroutine
    LDI   R21, 255         ; Load 255 into R21
l1:                        ; Label l1
    LDI   R22, 210         ; Load 210 into R22
l2:                        ; Label l2
    LDI   R23, 2           ; Load 2 into R23
l3:                        ; Label l3
    DEC   R23              ; Decrement R23
    BRNE  l3               ; Branch to l3 if R23 is not zero
    DEC   R22              ; Decrement R22
    BRNE  l2               ; Branch to l2 if R22 is not zero
    DEC   R21              ; Decrement R21
    BRNE  l1               ; Branch to l1 if R21 is not zero
    RET

delay_2s:                   ; Define delay_2s subroutine
    LDI   R21, 255         ; Load 255 into R21
l4:                        ; Label l4
    LDI   R22, 255         ; Load 255 into R22
l5:                        ; Label l5
    LDI   R23, 164         ; Load 164 into R23
l6:                        ; Label l6
    DEC   R23              ; Decrement R23
    BRNE  l6               ; Branch to l6 if R23 is not zero
    DEC   R22              ; Decrement R22
    BRNE  l5               ; Branch to l5 if R22 is not zero
    DEC   R21              ; Decrement R21
    BRNE  l4               ; Branch to l4 if R21 is not zero
    RET

delay_timer0:              ; Define delay_timer0 subroutine
    CLR   R20              ; Clear R20
    OUT   TCNT0, R20       ; Output R20 to TCNT0 register (Initialize timer0 with count=0)
    LDI   R20, 100         ; Load 100 into R20
    OUT   OCR0A, R20       ; Output R20 to OCR0A register (OCR0 = 100)
    LDI   R20, 0b00001010  ; Load binary 00001010 into R20
    OUT   TCCR0B, R20      ; Output R20 to TCCR0B register (Timer0: CTC mode, prescaler 8)
cTimer0:                   ; Label cTimer0
    IN    R20, TIFR0       ; Read TIFR0 into R20
    SBRS  R20, OCF0A       ; Skip next instruction if OCF0A flag is set
    RJMP  cTimer0          ; Jump to cTimer0 (Loop back & check OCF0 flag)
    CLR   R20              ; Clear R20
    OUT   TCCR0B, R20      ; Output R20 to TCCR0B register (Stop timer0)
    LDI   R20, (1<<OCF0A)  ; Load OCF0A flag into R20
    OUT   TIFR0, R20       ; Output R20 to TIFR0 register (Clear OCF0 flag)
    RET
