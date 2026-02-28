; ===================================================================
; HAMURABI 6502
; ===================================================================

; --- Zero Page ---
ACRES       = $45
ACRES_H     = $46
PRICE       = $47

HAMURABI_START:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_intro_hm
    sta STR_PTR
    lda #>msg_intro_hm
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD

    lda #1
    sta YEAR
    lda #90        
    sta POP
    lda #0
    sta POP_H
    lda #$DC       ; 2780
    sta STORES
    lda #$0A
    sta STORES_H
    lda #$E8       ; 1000
    sta ACRES
    lda #$03
    sta ACRES_H
    lda #$55
    sta $4F        

MAIN_LOOP_HM:
    lda #<msg_y
    sta STR_PTR
    lda #>msg_y
    sta STR_PTR_H
    jsr PRINT_STRING
    lda YEAR
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16
    
    lda #<msg_p
    sta STR_PTR
    jsr PRINT_STRING
    lda POP
    sta IN_VAL
    lda POP_H
    sta IN_VAL_H
    jsr PRINT_NUM_16

    lda #<msg_s
    sta STR_PTR
    jsr PRINT_STRING
    lda STORES
    sta IN_VAL
    lda STORES_H
    sta IN_VAL_H
    jsr PRINT_NUM_16

    lda #<msg_a
    sta STR_PTR
    jsr PRINT_STRING
    lda ACRES
    sta IN_VAL
    lda ACRES_H
    sta IN_VAL_H
    jsr PRINT_NUM_16

    jsr GET_RANDOM
    and #$07
    clc
    adc #17
    sta PRICE
    lda #<msg_pr
    sta STR_PTR
    jsr PRINT_STRING
    lda PRICE
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16

    ; --- Acquisto Acri ---
    lda #<msg_buy
    sta STR_PTR
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT 
    
    lda ACRES
    clc
    adc IN_VAL
    sta ACRES
    lda ACRES_H
    adc IN_VAL_H
    sta ACRES_H

    ; --- Input Cibo ---
    lda #<msg_feed
    sta STR_PTR
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT 

    lda STORES
    sec
    sbc IN_VAL
    sta STORES
    lda STORES_H
    sbc IN_VAL_H
    sta STORES_H
    bcs G_OK
    lda #0
    sta STORES
    sta STORES_H
G_OK:

    jsr CALC_FED
    lda POP
    sec
    sbc TEMP
    sta TEMP_H      
    bcs P_CHK
    lda #0
    sta TEMP_H
P_CHK:
    lda POP
    sec
    sbc TEMP_H
    sta POP
    lda POP_H
    sbc #0
    sta POP_H

    lda ACRES
    sta TEMP
    lda ACRES_H
    sta TEMP_H
    ldx #3
Y_LP:
    clc
    lda STORES
    adc TEMP
    sta STORES
    lda STORES_H
    adc TEMP_H
    sta STORES_H
    dex
    bne Y_LP

    lda POP
    clc
    adc #10
    sta POP
    lda POP_H
    adc #0
    sta POP_H

    inc YEAR
    lda YEAR
    cmp #11
    beq J_WIN       
    
    lda POP_H
    bne NEXT_L
    lda POP
    cmp #5
    bcc J_LOSE      

NEXT_L:
    lda #<msg_ok
    sta STR_PTR
    jsr PRINT_STRING
    jsr WAIT_KEY
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
jsr RESET_LCD
    jmp MAIN_LOOP_HM

; --- Ponti di Salto ---
J_WIN:  jmp WIN_L
J_LOSE: jmp LOSE_L

R_ESC:              
    pla             
    jmp HAMURABI_START
    jsr RESET_LCD


CALC_FED:
    lda #0
    sta TEMP
    sta TEMP_H
CF_LP:
    lda IN_VAL
    sec
    sbc #20
    sta IN_VAL
    lda IN_VAL_H
    sbc #0
    sta IN_VAL_H
    bcc CF_END
    inc TEMP
    bne CF_LP
    inc TEMP_H
    jmp CF_LP
CF_END:
    rts

J_ESC_EXIT:         
    jmp R_ESC

WIN_L:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_win
    sta STR_PTR
    lda #>msg_win
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    rts             

LOSE_L:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_lose
    sta STR_PTR
    lda #>msg_lose
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    jmp HAMURABI_START

; --- STRINGHE DI TESTO ---
msg_intro_hm:  .byte "--- HAMURABI ---", 13, "BABILONIA TI ATTENDE", 13, "GOVERNA PER 10 ANNI", 13, 13, "ESC PER USCIRE", 13, 0
msg_y:      .byte 13, "ANNO: ", 0
msg_p:      .byte 13, "POPOLO: ", 0
msg_s:      .byte 13, "GRANO: ", 0
msg_a:      .byte 13, "ACRI: ", 0
msg_pr:     .byte 13, "PREZZO: ", 0
msg_buy:    .byte 13, "ACRI? ", 0
msg_feed:   .byte 13, "GRANO x CIBO? ", 0
msg_ok:     .byte 13, 13, "TURNO CONCLUSO. ", 0
msg_lose:   .byte 13, "RIVOLTA! SEI STATO", 13, "DEPOSTO CON FORZA.", 0
msg_win:    .byte 13, "--- VITTORIA! ---", 13, 13
            .byte "FANTASTICO! HAI", 13
            .byte "GOVERNATO SAGGIAMENTE", 13
            .byte "PER 10 ANNI.", 13
            .byte "IL TUO NOME RESTERA'", 13
            .byte "NELLA STORIA.", 13, 13, 0