; ===================================================================
; BOWLING 65C02 - VERSION 2026
; ===================================================================

; --- Zero Page ---
FRAME       = $60   
PINS_MASK   = $62   
PINS_MASK_H = $63   
SCORE       = $64   
SCORE_H     = $65   
ROLL_RES    = $66   
TEMP_BIT    = $67
CUR_IDX     = $68

BOWLING_START:
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #$FF
    sta $4F
    lda #<msg_intro
    sta STR_PTR
    lda #>msg_intro
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne @no_esc_start
    jmp EXIT_TO_MENU
@no_esc_start:

    lda #1
    sta FRAME
    lda #0
    sta SCORE
    sta SCORE_H

MAIN_LOOP:
    lda #%11111111 
    sta PINS_MASK
    lda #%00000011
    sta PINS_MASK_H

FRAME_LOOP:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    jsr PRINT_STATUS
    jsr DRAW_PINS
    
    lda #<m_roll1
    sta STR_PTR
    lda #>m_roll1
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne no_esc1
    jmp EXIT_TO_MENU
no_esc1:    

    jsr EXEC_ROLL
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    jsr PRINT_STATUS
    jsr DRAW_PINS
    jsr SHOW_RES

    lda PINS_MASK
    ora PINS_MASK_H
    beq IS_STRIKE

    lda #<m_roll2
    sta STR_PTR
    lda #>m_roll2
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne no_esc2
    jmp EXIT_TO_MENU
no_esc2:    

    jsr EXEC_ROLL
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    jsr PRINT_STATUS
    jsr DRAW_PINS       
    jsr SHOW_RES

    lda PINS_MASK
    ora PINS_MASK_H
    beq IS_SPARE
    
    lda #<m_next
    sta STR_PTR
    lda #>m_next
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne no_esc3
    jmp EXIT_TO_MENU
no_esc3:
    jmp NEXT_F

IS_STRIKE:
    lda #<m_strike
    sta STR_PTR
    lda #>m_strike
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne no_esc_str
    jmp EXIT_TO_MENU
no_esc_str:
    jmp NEXT_F

IS_SPARE:
    lda #<m_spare
    sta STR_PTR
    lda #>m_spare
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    bne no_esc_spa
    jmp EXIT_TO_MENU
no_esc_spa:    

NEXT_F:
    inc FRAME
    lda FRAME
    cmp #11
    beq BOW_WIN
    jmp MAIN_LOOP

BOW_WIN:
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<m_done
    sta STR_PTR
    lda #>m_done
    sta STR_PTR_H
    jsr PRINT_STRING
    
    lda #<m_fin_sc
    sta STR_PTR
    lda #>m_fin_sc
    sta STR_PTR_H
    jsr PRINT_STRING
    
    lda SCORE
    sta IN_VAL
    lda SCORE_H
    sta IN_VAL_H
    jsr PRINT_NUM_16
    
    jsr WAIT_KEY
    jmp BOWLING_START

; --- Grafica e Centratura ---

DRAW_PINS:
    pha
    phx
    phy
    lda #$0D
    jsr CHROUT
    lda #$0D
    jsr CHROUT
    
    ; Riga 4
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    ldx #6
    jsr DRAW_BIT
    ldx #7
    jsr DRAW_BIT
    ldx #8
    jsr DRAW_BIT
    ldx #9
    jsr DRAW_BIT
    lda #$0D
    jsr CHROUT
    
    ; Riga 3
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    ldx #3
    jsr DRAW_BIT
    ldx #4
    jsr DRAW_BIT
    ldx #5
    jsr DRAW_BIT
    lda #$0D
    jsr CHROUT
    
    ; Riga 2
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    ldx #1
    jsr DRAW_BIT
    ldx #2
    jsr DRAW_BIT
    lda #$0D
    jsr CHROUT
    
    ; Riga 1
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    jsr PR_SP
    ldx #0
    jsr DRAW_BIT
    lda #$0D
    jsr CHROUT
    
    ply
    plx
    pla
    rts

DRAW_BIT:
    pha
    phx
    phy
    stx CUR_IDX
    cpx #8
    bcc l
    lda PINS_MASK_H
    cpx #8
    beq z8
    lsr a
    jmp c
z8:
    and #1
    jmp c
l:
    lda PINS_MASK
    ldy CUR_IDX
    beq c
s:
    lsr a
    dey
    bne s
c:
    and #1
    beq off
    lda #'+'
    jmp p
off:
    lda #'0'
p:
    jsr CHROUT
    jsr PR_SP
    ply
    plx
    pla
    rts

EXEC_ROLL:
    pha
    phx
    phy
    lda #0
    sta ROLL_RES
    ldy #10
lp:
    phy
    jsr GET_RANDOM
    ply
    cmp #$B0
    bcc sk
    tya
    tax
    dex
    jsr HIT_PIN
sk:
    dey
    bne lp
    ply
    plx
    pla
    rts

HIT_PIN:
    pha
    phx
    phy
    stx TEMP_BIT
    cpx #8
    bcc low
    cpx #8
    beq b8
    lda PINS_MASK_H
    and #2
    beq ex
    lda PINS_MASK_H
    eor #2
    sta PINS_MASK_H
    inc ROLL_RES
    jmp ex
b8:
    lda PINS_MASK_H
    and #1
    beq ex
    lda PINS_MASK_H
    eor #1
    sta PINS_MASK_H
    inc ROLL_RES
    jmp ex
low:
    lda #1
    ldy TEMP_BIT
    beq nok
sl:
    asl a
    dey
    bne sl
nok:
    sta CUR_IDX
    lda PINS_MASK
    and CUR_IDX
    beq ex
    lda PINS_MASK
    eor CUR_IDX
    sta PINS_MASK
    inc ROLL_RES
ex:
    ply
    plx
    pla
    rts

PRINT_STATUS:
    pha
    phx
    phy
    lda #<m_frame
    sta STR_PTR
    lda #>m_frame
    sta STR_PTR_H
    jsr PRINT_STRING
    lda FRAME
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16
    lda #<m_pts
    sta STR_PTR
    lda #>m_pts
    sta STR_PTR_H
    jsr PRINT_STRING
    lda SCORE
    sta IN_VAL
    lda SCORE_H
    sta IN_VAL_H
    jsr PRINT_NUM_16
    ply
    plx
    pla
    rts

SHOW_RES:
    pha
    phx
    phy
    lda #<m_hit
    sta STR_PTR
    lda #>m_hit
    sta STR_PTR_H
    jsr PRINT_STRING
    lda ROLL_RES
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16
    lda SCORE
    clc
    adc ROLL_RES
    sta SCORE
    lda SCORE_H
    adc #0
    sta SCORE_H
    ply
    plx
    pla
    rts

PR_SP:
    pha
    lda #$20
    jsr CHROUT
    pla
    rts


msg_intro: .byte 13, "---   BOWLING   ---", 13, "PRONTO?", 0
m_frame:   .byte 13, "FRAME: ", 0
m_pts:     .byte " PUNTI: ", 0
m_roll1:   .byte 13, "LANCIO 1 (KEY)", 0
m_roll2:   .byte 13, "LANCIO 2 (KEY)", 0
m_hit:     .byte 13, "COLPITI: ", 0
m_strike:  .byte 13, "STRIKE!!", 0
m_spare:   .byte 13, "SPARE!", 0
m_next:    .byte 13, "CONTINUA (KEY)", 0
m_done:    .byte 13, "FINE GIOCO!", 13, 0
m_fin_sc:  .byte "PUNTEGGIO FINALE: ", 0
