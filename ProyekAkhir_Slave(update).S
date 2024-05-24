#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main

main:
  ; Set PB3 as output (LED)
  SBI DDRB, 3
  ; Set PD7 as output (fan motor)
  SBI DDRD, 7

  ; USART Initialization
  CLR R24              ; Clear R24
  STS UCSR0A, R24      ; Clear UCSR0A register
  STS UBRR0H, R24      ; Clear UBRR0H register
  LDI R24, 103         ; Load baud rate divisor 103 into R24
  STS UBRR0L, R24      ; Store R24 into UBRR0L register
  LDI R24, (1<<RXEN0) | (1<<TXEN0)  ; Enable receiver and transmitter
  STS UCSR0B, R24      ; Store R24 into UCSR0B register
  LDI R24, (1<<UCSZ00) | (1<<UCSZ01) ; Set frame format: 8 data bits, 1 stop bit
  STS UCSR0C, R24      ; Store R24 into UCSR0C register

  ; ADC Initialization
  SBI DDRC, 0          ; Set PC0 as input (ADC0)
  LDI R20, 0xC0        ; Internal 2.56V, right-justified data, ADC0
  STS ADMUX, R20
  LDI R20, 0x87        ; Enable ADC, prescaler 128
  STS ADCSRA, R20

main_loop:
  RJMP loop1
loop1:
  ; Read temperature from I2C
  RCALL I2C_init
  RCALL I2C_listen
  RCALL I2C_read
  RCALL printval      ; Print temperature value
  RCALL space
  MOV R27, R26        ; Copy R26 into R27
  RCALL check_temp    ; Call check_temp subroutine
  RJMP loop2          ; Jump to loop2

loop2:
  ; Read and print ADC value
  RCALL print_ADC       ; Print ADC value
  RCALL check_light  
  RCALL newline
  ; Jump back to loop1
  RJMP loop1

; Subroutine to read ADC
read_ADC:
  LDI R20, 0xC7        ; Start ADC conversion
  STS ADCSRA, R20
wait_ADC:
  LDS R21, ADCSRA      ; Check if conversion is complete
  SBRS R21, 4          ; If ADIF not set, skip next instruction
  RJMP wait_ADC        ; Wait until conversion is done
  LDI R17, 0xD7        ; Clear ADIF flag
  STS ADCSRA, R17
  LDS R18, ADCL        ; Read ADC low byte
  LDS R19, ADCH        ; Read ADC high byte
  RET

; Subroutine to print ADC value
print_ADC:
  RCALL read_ADC       ; Read ADC value
  ; Combine high and low bytes to form the 10-bit ADC value
  LDI R25, 0           ; Clear R25
  MOV R25, R19         ; Move high byte to R25
  SWAP R25             ; Swap nibbles to align high bits
  ANDI R25, 0x03       ; Mask out all but 2 LSBs of high byte
  MOV R26, R18         ; Move low byte to R26
  OR R26, R25          ; Combine with high byte
  RCALL printval       ; Print the 10-bit ADC value
  RET

; 1 second delay subroutine
delay_sec:
  LDI R20, 255
l6: LDI R21, 255
l7: LDI R22, 80
l8: DEC R22
  BRNE l8
  DEC R21
  BRNE l7
  DEC R20
  BRNE l6
  RET

; I2C initialization
I2C_init:
  LDI R21, 0b10010000
  STS TWAR, R21
  LDI R21, (1<<TWEN)
  STS TWCR, R21
  LDI R21, (1<<TWINT) | (1<<TWEN) | (1<<TWEA)
  STS TWCR, R21
  RET

; I2C listen
I2C_listen:
  LDS R21, TWCR
  SBRS R21, TWINT
  RJMP I2C_listen
  RET

; I2C read
I2C_read:
  LDI R21, (1<<TWINT) | (1<<TWEA) | (1<<TWEN)
  STS TWCR, R21

wt:
  LDS R21, TWCR
  SBRS R21, TWINT
  RJMP wt
  LDS R26, TWDR
  RET

; Print value subroutine
printval:
  MOV R16, R26
  RCALL ASCII_MSD
  RCALL LCD_buffer
  STS UDR0, R16
  RCALL ASCII_LSD
  RCALL LCD_buffer
  STS UDR0, R16
  RET

; USART buffer check
LCD_buffer:
  LDS R24, UCSR0A
  SBRS R24, UDRE0
  RJMP LCD_buffer
  RET

; Convert to ASCII Most Significant Digit
ASCII_MSD:
  MOV R23, R16
  ANDI R16, 0xF0
  SWAP R16
  SUBI R16, -48
  MOV R28, R16
  SUBI R28, 58
  BRPL A_F_D1
l1:
  RET
A_F_D1:
  SUBI R16, -7
  RJMP l1

; Convert to ASCII Least Significant Digit
ASCII_LSD:
  MOV R16, R23
  ANDI R16, 0x0F
  SUBI R16, -48
  MOV R28, R16
  SUBI R28, 58
  BRPL A_F_D0
l2:
  RET
A_F_D0:
  SUBI R16, -7
  RJMP l2

; Print space character
space:
  RCALL LCD_buffer
  LDI R25, 0x20
  STS UDR0, R25
  RET

; Print newline characters
newline:
  RCALL LCD_buffer
  LDI R24, 0x0A
  STS UDR0, R24
  RCALL LCD_buffer
  LDI R24, 0x0D
  STS UDR0, R24
  RET

; Check temperature
check_temp:
  CPI R27, 30
  BRSH fan_on
  CBI PORTD, 7
  RET

fan_on:
  SBI PORTD, 7
  RET

; Check light
check_light:
  LDI R26, 0x09
  CP R18, R26
  BRSH LED_ON
  CBI PORTD, 6
  RJMP control_end
LED_ON:
  SBI PORTD, 6
control_end:
  RET

; Turn off LED
LED_off:
  CBI PORTB, 3
  RET
