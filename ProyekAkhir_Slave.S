#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main

main:
    ; Set PB3 as output (LED)
    SBI DDRB, 3         ; Set PB3 as output for LED
    ; Set PD7 as output (fan motor)
    SBI DDRD, 7         ; Set PD7 as output for fan motor

    ; USART Initialization
    CLR R24             ; Clear R24 register
    STS UCSR0A, R24     ; Store R24 in UCSR0A register
    STS UBRR0H, R24     ; Store R24 in UBRR0H register
    LDI R24, 103        ; Load 103 into R24 (baud rate)
    STS UBRR0L, R24     ; Store R24 in UBRR0L register
    LDI R24, (1<<RXEN0) | (1<<TXEN0) ; Load enable flags into R24
    STS UCSR0B, R24     ; Store R24 in UCSR0B register
    LDI R24, (1<<UCSZ00) | (1<<UCSZ01) ; Load UCSZ flags into R24
    STS UCSR0C, R24     ; Store R24 in UCSR0C register

    ; ADC Initialization
    SBI DDRC, 0         ; Set PC0 as input for ADC
    LDI R20, 0xC0       ; Load 0xC0 into R20
    STS ADMUX, R20      ; Store R20 in ADMUX register (ADC reference and channel selection)
    LDI R20, 0x87       ; Load 0x87 into R20
    STS ADCSRA, R20     ; Store R20 in ADCSRA register (ADC enable and prescaler)

main_loop:
    RJMP loop1          ; Jump to loop1

loop1:
    RCALL delay_20ms    ; Call delay subroutine
    ; Read temperature from I2C
    RCALL I2C_init      ; Call I2C initialization
    RCALL I2C_listen    ; Call I2C listen
    RCALL I2C_read      ; Call I2C read (low byte of LDR data)
    MOV R18, R26        ; Move data from R26 to R18
    RCALL I2C_read      ; Call I2C read (high byte of LDR data)
    MOV R19, R26        ; Move data from R26 to R19
    RCALL I2C_read      ; Call I2C read (temperature data from DHT11)
    MOV R27, R26        ; Move data from R26 to R27
    RCALL printval      ; Call print value subroutine
    RCALL space         ; Call space subroutine
    RCALL check_temp    ; Call check temperature subroutine
    RJMP loop2          ; Jump to loop2

loop2:
    LDI R17, 0x32       ; Load threshold value into R17 (50 in decimal)
    ; Read and print ADC value
    RCALL print_ADC     ; Call print_ADC subroutine
    RCALL newline       ; Call newline subroutine
    RCALL check_light   ; Call check light subroutine
    RJMP loop1          ; Jump to loop1

print_ADC:
    ; Combine high and low bytes to form the 10-bit ADC value
    LDI R25, 0          ; Load 0 into R25
    MOV R25, R19        ; Move data from R19 to R25
    SWAP R25            ; Swap nibbles in R25
    ANDI R25, 0x03      ; Mask higher bits, keep lower 2 bits
    MOV R26, R18        ; Move data from R18 to R26
    OR R26, R25         ; OR R26 with R25
    RCALL printval      ; Call print value subroutine
    RET                 ; Return from subroutine

; I2C Initialization
I2C_init:
    LDI R21, 0b10010000 ; Load I2C address into R21
    STS TWAR, R21       ; Store R21 in TWAR register
    LDI R21, (1<<TWEN)  ; Load enable flag into R21
    STS TWCR, R21       ; Store R21 in TWCR register
    LDI R21, (1<<TWINT) | (1<<TWEN) | (1<<TWEA) ; Load control flags into R21
    STS TWCR, R21       ; Store R21 in TWCR register
    RET                 ; Return from subroutine

; I2C Listen
I2C_listen:
    LDS R21, TWCR       ; Load TWCR into R21
    SBRS R21, TWINT     ; Skip if TWINT is set
    RJMP I2C_listen     ; Jump to I2C_listen
    RET                 ; Return from subroutine

; I2C Read
I2C_read:
    LDI R21, (1<<TWINT) | (1<<TWEA) | (1<<TWEN) ; Load control flags into R21
    STS TWCR, R21       ; Store R21 in TWCR register
wait:
    LDS R21, TWCR       ; Load TWCR into R21
    SBRS R21, TWINT     ; Skip if TWINT is set
    RJMP wait           ; Jump to wait
    LDS R26, TWDR       ; Load TWDR into R26
    RET                 ; Return from subroutine

delay_20ms:
    LDI   R21, 255      ; Load 255 into R21
lo1:
    LDI   R22, 210      ; Load 210 into R22
lo2:
    LDI   R23, 2        ; Load 2 into R23
lo3:
    DEC   R23           ; Decrement R23
    BRNE  lo3           ; Branch if not equal to zero
    DEC   R22           ; Decrement R22
    BRNE  lo2           ; Branch if not equal to zero
    DEC   R21           ; Decrement R21
    BRNE  lo1           ; Branch if not equal to zero
    RET                 ; Return from subroutine

; Print value subroutine
printval:
    MOV R16, R26        ; Move data from R26 to R16
    RCALL ASCII_MSD     ; Call ASCII_MSD subroutine
    RCALL LCD_buffer    ; Call LCD_buffer subroutine
    STS UDR0, R16       ; Store R16 in UDR0 register
    RCALL ASCII_LSD     ; Call ASCII_LSD subroutine
    RCALL LCD_buffer    ; Call LCD_buffer subroutine
    STS UDR0, R16       ; Store R16 in UDR0 register
    RET                 ; Return from subroutine

; USART buffer check
LCD_buffer:
    LDS R24, UCSR0A     ; Load UCSR0A into R24
    SBRS R24, UDRE0     ; Skip if UDRE0 is set
    RJMP LCD_buffer     ; Jump to LCD_buffer
    RET                 ; Return from subroutine

; Convert to ASCII Most Significant Digit
ASCII_MSD:
    MOV R23, R16        ; Move data from R16 to R23
    ANDI R16, 0xF0      ; Mask lower 4 bits of R16
    SWAP R16            ; Swap nibbles in R16
    SUBI R16, -48       ; Convert to ASCII
    MOV R28, R16        ; Move data from R16 to R28
    SUBI R28, 58        ; Check if digit is greater than 9
    BRPL A_F_D1         ; Branch if less than or equal to 9
l1:
    RET                 ; Return from subroutine
A_F_D1:
    SUBI R16, -7        ; Convert to hex ASCII
    RJMP l1             ; Jump to l1

; Convert to ASCII Least Significant Digit
ASCII_LSD:
    MOV R16, R23        ; Move data from R23 to R16
    ANDI R16, 0x0F      ; Mask higher 4 bits of R16
    SUBI R16, -48       ; Convert to ASCII
    MOV R28, R16        ; Move data from R16 to R28
    SUBI R28, 58        ; Check if digit is greater than 9
    BRPL A_F_D0         ; Branch if less than or equal to 9
l2:
    RET                 ; Return from subroutine
A_F_D0:
    SUBI R16, -7        ; Convert to hex ASCII
    RJMP l2             ; Jump to l2

; Print space character
space:
    RCALL LCD_buffer    ; Call LCD_buffer subroutine
    LDI R25, 0x20       ; Load space character into R25
    STS UDR0, R25       ; Store R25 in UDR0 register
    RET                 ; Return from subroutine

; Print newline characters
newline:
    RCALL LCD_buffer    ; Call LCD_buffer subroutine
    LDI R24, 0x0A       ; Load newline character into R24
    STS UDR0, R24       ; Store R24 in UDR0 register
    RCALL LCD_buffer    ; Call LCD_buffer subroutine
    LDI R24, 0x0D       ; Load carriage return character into R24
    STS UDR0, R24       ; Store R24 in UDR0 register
    RET                 ; Return from subroutine

; Check temperature
check_temp:
    CPI R27, 30         ; Compare temperature with threshold (30)
    BRSH fan_on         ; Branch if temperature is greater than or equal
    CBI PORTD, 7        ; Clear PD7 (turn off fan)
    RET                 ; Return from subroutine

fan_on:
    SBI PORTD, 7        ; Set PD7 (turn on fan)
    RET                 ; Return from subroutine

; Check light and control LED
check_light:
    CP R17, R18         ; Compare LDR value with threshold
    BRLO LED_off        ; Branch if LDR value is lower
    SBI PORTB, 3        ; Set PB3 (turn on LED)
    RET                 ; Return from subroutine

; Turn off LED
LED_off:
    CBI PORTB, 3        ; Clear PB3 (turn off LED)
    RET                 ; Return from subroutine
