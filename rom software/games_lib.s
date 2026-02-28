; ===================================================================
; GAMES_LIB.ASM - SYSTEM ROUTINE
; ===================================================================
.segment "GAMES"

ESC_KEY     = $1B

YEAR        = $40
;POP         = $41
POP_H       = $42
STORES      = $43
STORES_H    = $44
IN_VAL      = $4D
IN_VAL_H    = $4E
TEMP        = $4B
TEMP_H      = $4C
STR_PTR     = $20
STR_PTR_H   = $21
M10_T       = $22

CLS:
    lda #$1B
    jsr CHROUT
    lda #'['
    jsr CHROUT
    lda #'2'
    jsr CHROUT
    lda #'J'
    jsr CHROUT
    lda #$1B
    jsr CHROUT
    lda #'['
    jsr CHROUT
    lda #'H'
    jsr CHROUT
    rts

PRINT_STRING:
    ldy #0
PS_LOOP:
    lda (STR_PTR),y
    beq PS_END
    jsr CHROUT
    iny
    bne PS_LOOP
    inc STR_PTR_H
    jmp PS_LOOP
PS_END:
    rts

PRINT_NUM_16:
    ldx #0
    stx TEMP_H
    ldx #$FF
P10K: 
    inx
    lda IN_VAL
    sec
    sbc #<10000
    sta IN_VAL
    lda IN_VAL_H
    sbc #>10000
    sta IN_VAL_H
    bcs P10K
    lda IN_VAL
    adc #<10000
    sta IN_VAL
    lda IN_VAL_H
    adc #>10000
    sta IN_VAL_H
    txa
    beq P1K
    clc
    adc #$30
    jsr CHROUT
    inc TEMP_H
P1K: 
    ldx #$FF
P1KL: 
    inx
    lda IN_VAL
    sec
    sbc #<1000
    sta IN_VAL
    lda IN_VAL_H
    sbc #>1000
    sta IN_VAL_H
    bcs P1KL
    lda IN_VAL
    adc #<1000
    sta IN_VAL
    lda IN_VAL_H
    adc #>1000
    sta IN_VAL_H
    txa
    bne P1KD
    lda TEMP_H
    beq P100
P1KD: 
    clc
    adc #$30
    jsr CHROUT
    inc TEMP_H
P100: 
    ldx #$FF
P100L: 
    inx
    lda IN_VAL
    sec
    sbc #100
    sta IN_VAL
    lda IN_VAL_H
    sbc #0
    sta IN_VAL_H
    bcs P100L
    lda IN_VAL
    adc #100
    sta IN_VAL
    txa
    bne P100D
    lda TEMP_H
    beq P10
P100D: 
    clc
    adc #$30
    jsr CHROUT
    inc TEMP_H
P10: 
    ldx #$FF
P10L: 
    inx
    lda IN_VAL
    sec
    sbc #10
    sta IN_VAL
    bcs P10L
    lda IN_VAL
    adc #10
    sta IN_VAL
    txa
    bne P10D
    lda TEMP_H
    beq P1
P10D: 
    clc
    adc #$30
    jsr CHROUT
P1: 
    lda IN_VAL
    clc
    adc #$30
    jsr CHROUT
    rts

READ_INPUT_SILENT:
    lda #0
    sta IN_VAL
    sta IN_VAL_H
RI_LP: 
    jsr CHRIN
    bcc RI_LP                  ; beq RI_LP
    cmp #ESC_KEY      ; Controlla se è stato premuto ESC
    beq EXIT_TO_MENU  ; Salta al menu principale
    cmp #$0D
    beq RI_DONE
    sec
    sbc #$30
    sta RI_T
    jsr MUL10
    lda IN_VAL
    clc
    adc RI_T
    sta IN_VAL
    lda IN_VAL_H
    adc #0
    sta IN_VAL_H
    jmp RI_LP
RI_DONE: 
    lda #$0D
    jsr CHROUT
    rts

EXIT_TO_MENU:
    pla 
    pla
    jmp go_program    

RI_T: .byte 0

GET_RANDOM:
    lda $4F
    asl a
    bcc GR_N
    eor #$1D
GR_N: 
    sta $4F
    rts

WAIT_KEY:
    jsr CHRIN_NO_ECHO
    beq WAIT_KEY
    rts