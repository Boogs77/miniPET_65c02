.segment "CODE"
.ifdef EATER
PORTB1 = $D000
DDRB1  = $D002
E1  = %01000000
RW1 = %00100000
RS1 = %00010000

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB1
lcdbusy:
  lda #RW1
  sta PORTB1
  lda #(RW1 | E1)
  sta PORTB1
  lda PORTB1       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW1
  sta PORTB1
  lda #(RW1 | E1)
  sta PORTB1
  lda PORTB1       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW1
  sta PORTB1
  lda #%11111111  ; LCD data is output
  sta DDRB1
  pla
  rts

LCDINIT:
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB1
  
  lda #%00000011        ; Set 8-bit mode - repeat 3 times before 4-bit because reddit said so
  sta PORTB1             ; https://www.reddit.com/r/beneater/comments/1caanm9/help_troubleshooting_r65c51_acia/
  ora #E1
  lda #%00000011        ; Set 8-bit mode
  sta PORTB1
  ora #E1
  lda #%00000011        ; Set 8-bit mode
  sta PORTB1
  ora #E1
  lda #%00000010        ; Set 4-bit mode
  sta PORTB1
  ora #E1
  sta PORTB1
  and #%00001111
  sta PORTB1
  
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  rts

LCDCMD:
  jsr GETBYT ; Read from POKE command
  txa
lcd_instruction:    
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB1
  ora #E1         ; Set E bit to send instruction
  sta PORTB1
  eor #E1         ; Clear E bit
  sta PORTB1
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB1
  ora #E1        ; Set E bit to send instruction
  sta PORTB1
  eor #E1         ; Clear E bit
  sta PORTB1
  rts

LCDPRINT:
  jsr FRMEVL
  bit VALTYP
  bmi lcd_print
  jsr FOUT
  jsr STRLIT
lcd_print:
  jsr FREFAC
  tax
  ldy #0
lcd_print_loop:
  lda (INDEX),y
  jsr lcd_print_char
  iny
  dex
  bne lcd_print_loop
  rts

lcd_print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS1         ; Set RS
  sta PORTB1
  ora #E1         ; Set E bit to send instruction
  sta PORTB1
  eor #E1          ; Clear E bit
  sta PORTB1
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS1         ; Set RS
  sta PORTB1
  ora #E1          ; Set E bit to send instruction
  sta PORTB1
  eor #E1          ; Clear E bit
  sta PORTB1
  rts

.endif

.ifdef BOOGS
PORTB1 = $D000
DDRB1  = $D002
E1  = %01000000
RW1 = %00100000
RS1 = %00010000

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB1
lcdbusy:
  lda #RW1
  sta PORTB1
  lda #(RW1 | E1)
  sta PORTB1
  lda PORTB1       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW1
  sta PORTB1
  lda #(RW1 | E1)
  sta PORTB1
  lda PORTB1       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW1
  sta PORTB1
  lda #%11111111  ; LCD data is output
  sta DDRB1
  pla
  rts

LCDINIT:
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB1
  
  lda #%00000011        ; Set 8-bit mode - repeat 3 times before 4-bit because reddit said so
  sta PORTB1             ; https://www.reddit.com/r/beneater/comments/1caanm9/help_troubleshooting_r65c51_acia/
  ora #E1
  lda #%00000011        ; Set 8-bit mode
  sta PORTB1
  ora #E1
  lda #%00000011        ; Set 8-bit mode
  sta PORTB1
  ora #E1
  lda #%00000010        ; Set 4-bit mode
  sta PORTB1
  ora #E1
  sta PORTB1
  and #%00001111
  sta PORTB1
  
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  rts

LCDCMD:
  jsr GETBYT ; Read from POKE command
  txa
lcd_instruction:    
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB1
  ora #E1         ; Set E bit to send instruction
  sta PORTB1
  eor #E1         ; Clear E bit
  sta PORTB1
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB1
  ora #E1         ; Set E bit to send instruction
  sta PORTB1
  eor #E1         ; Clear E bit
  sta PORTB1
  rts

LCDPRINT:
  jsr FRMEVL
  bit VALTYP
  bmi lcd_print
  jsr FOUT
  jsr STRLIT
lcd_print:
  jsr FREFAC
  tax
  ldy #0
lcd_print_loop:
  lda (INDEX),y
  jsr lcd_print_char
  iny
  dex
  bne lcd_print_loop
  rts

lcd_print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS1         ; Set RS
  sta PORTB1
  ora #E1          ; Set E bit to send instruction
  sta PORTB1
  eor #E1          ; Clear E bit
  sta PORTB1
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS1         ; Set RS
  sta PORTB1
  ora #E1          ; Set E bit to send instruction
  sta PORTB1
  eor #E1          ; Clear E bit
  sta PORTB1
  rts

.endif