#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main

main:
  SBI DDRB, 3         ; Set PB3 as output (LED)
  SBI DDRD, 7         ; Set PD7 as output (fan motor)

  CLR R24             ; Clear R24
  STS UCSR0A, R24     ; Clear UCSR0A register
  STS UBRR0H, R24     ; Clear UBRR0H register
  LDI R24, 103        ; Load baud rate divisor 103 into R24
  STS UBRR0L, R24     ; Store R24 into UBRR0L register
  LDI R24, (1<<RXEN0) | (1<<TXEN0)   ; Load USART control and status flags into R24
  STS UCSR0B, R24     ; Store R24 into UCSR0B register
  LDI R24, (1<<UCSZ00) | (1<<UCSZ01) ; Load USART character size flags into R24
  STS UCSR0C, R24     ; Store R24 into UCSR0C register

call_sub:
  RCALL I2C_init      ; Call I2C_init subroutine
  RCALL I2C_listen    ; Call I2C_listen subroutine
  RCALL I2C_read      ; Call I2C_read subroutine
  RCALL printval      ; Call printval subroutine
  RJMP call_sub

I2C_init:
  LDI R21, 0b10010000 ; Load 0b10010000 into R21
  STS TWAR, R21       ; Store R21 into TWAR register
  LDI R21, (1<<TWEN)  ; Load TWEN flag into R21
  STS TWCR, R21       ; Store R21 into TWCR register
  LDI R21, (1<<TWINT) | (1<<TWEN) | (1<<TWEA) ; Load TWINT, TWEN, and TWEA flags into R21
  STS TWCR, R21       ; Store R21 into TWCR register
  RET

I2C_listen:
  LDS R21, TWCR       ; Load value from TWCR register into R21
  SBRS R21, TWINT     ; Skip next instruction if TWINT flag is not set
  RJMP I2C_listen     ; Jump to I2C_listen
  RET

I2C_read:
  LDI R21, (1<<TWINT) | (1<<TWEA) | (1<<TWEN) ; Load TWINT, TWEA, and TWEN flags into R21
  STS TWCR, R21       ; Store R21 into TWCR register

wt:
  LDS R21, TWCR       ; Load value from TWCR register into R21
  SBRS R21, TWINT     ; Skip next instruction if TWINT flag is not set
  RJMP wt             ; Jump to wt
  LDS R26, TWDR       ; Load value from TWDR register into R26
  RET

LCD_buffer:
  LDS R26, UCSR0A     ; Load status register of USART0 into R26
  SBRS R26, UDRE0     ; Skip next instruction if USART data buffer is not empty
  RJMP LCD_buffer     ; Loop back to LCD_buffer
  RET

ASCII_MSD:
  MOV R23, R16        ; Copy R16 into R23
  ANDI R16, 0xF0      ; Mask the lower nibble of R16
  SWAP R16            ; Swap the nibbles of R16
  SUBI R16, -48       ; Convert to ASCII
  MOV R28, R16        ; Copy R16 into R28
  SUBI R28, 58        ; Subtract 58 from R28
  BRPL A_F_D1         ; Branch if positive to A_F_D1
l1:
  RET
A_F_D1:
  SUBI R16, -7        ; Subtract -7 from R16
  RJMP l1             ; Jump to l1

ASCII_LSD:
  MOV R16, R23        ; Copy R23 into R16
  ANDI R16, 0x0F      ; Mask the upper nibble of R16
  SUBI R16, -48       ; Convert to ASCII
  MOV R28, R16        ; Copy R16 into R28
  SUBI R28, 58        ; Subtract 58 from R28
  BRPL A_F_D0         ; Branch if positive to A_F_D0
l2:
  RET
A_F_D0:               ; Label A_F_D0
  SUBI R16, -7        ; Subtract -7 from R16
  RJMP l2             ; Jump to l2

newline:
  RCALL LCD_buffer    ; Call LCD_buffer subroutine
  LDI R16, 0x0A       ; Load ASCII value for new line character into R16
  STS UDR0, R16       ; Store R16 into USART0 data register
  RCALL LCD_buffer    ; Call LCD_buffer subroutine
  LDI R16, 0x0D       ; Load ASCII value for carriage return character into R16
  STS UDR0, R16       ; Store R16 into USART0 data register
  RET

printval:
  MOV R16, R26        ; Copy R26 into R16
  RCALL ASCII_MSD     ; Call ASCII_MSD subroutine
  RCALL LCD_buffer    ; Call LCD_buffer subroutine
  STS UDR0, R16       ; Store R16 into USART0 data register
  RCALL ASCII_LSD     ; Call ASCII_LSD subroutine
  RCALL LCD_buffer    ; Call LCD_buffer subroutine
  STS UDR0, R16       ; Store R16 into USART0 data register
  RCALL newline       ; Call newline subroutine

  ; Check temperature value and control fan
  CPI R26, 30         ; Compare value of R26 with 30
  BRSH fan_on         ; Branch if value is same or higher than 30
  CBI PORTD, 7        ; Turn off the fan
  RJMP call_sub

fan_on:
  SBI PORTD, 7        ; Turn on the fan
  RJMP call_sub       ; Return to the call_sub