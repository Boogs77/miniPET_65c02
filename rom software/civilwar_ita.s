; ===================================================================
; CIVIL WAR 1861
; ===================================================================

B_ID        = $77   
SIDE        = $78  

START:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_intro_cw
    sta STR_PTR
    lda #>msg_intro_cw
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne no_esc_start
    jmp EXIT_TO_MENU
no_esc_start:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_choose
    sta STR_PTR
    lda #>msg_choose
    sta STR_PTR_H
    jsr PRINT_STRING
    
ask_side:
    jsr CHRIN
    cmp #'1'
    beq set_north
    cmp #'2'
    beq set_south
    cmp #ESC_KEY
    bne ask_side
    jmp EXIT_TO_MENU

set_north:
    lda #0
    sta SIDE
    jmp init_game
set_south:
    lda #1
    sta SIDE

init_game:
    lda #61
    sta YEAR
    lda #0          
    sta B_ID
    lda #<2500      
    sta POP
    lda #>2500
    sta POP_H
    lda #<1000      
    sta STORES
    lda #>1000
    sta STORES_H
    lda #$7F        
    sta $4F

MAIN_LOOP_CW:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    
    ; Rendita annuale automatica (+500 Oro)
    clc
    lda STORES
    adc #<500
    sta STORES
    lda STORES_H
    adc #>500
    sta STORES_H

    ; Anno
    lda #<m_yr
    sta STR_PTR
    lda #>m_yr
    sta STR_PTR_H
    jsr PRINT_STRING
    lda YEAR
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16

    ; Uomini
    lda #<m_m
    sta STR_PTR
    lda #>m_m
    sta STR_PTR_H
    jsr PRINT_STRING
    lda POP
    sta IN_VAL
    lda POP_H
    sta IN_VAL_H
    jsr PRINT_NUM_16

    ; Oro
    lda #<m_g
    sta STR_PTR
    lda #>m_g
    sta STR_PTR_H
    jsr PRINT_STRING
    lda STORES
    sta IN_VAL
    lda STORES_H
    sta IN_VAL_H
    jsr PRINT_NUM_16

    ; --- FASE ARRUOLAMENTO ---
    lda #<m_rec
    sta STR_PTR
    lda #>m_rec
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT 
    
    ; Calcolo costo: IN_VAL * 2 (Sposta input in TEMP per calcolo)
    lda IN_VAL
    sta TEMP
    lda IN_VAL_H
    sta TEMP_H
    
    asl TEMP        ; Moltiplica per 2 (Costo Oro)
    rol TEMP_H

    ; Sottrai oro (STORES = STORES - TEMP)
    sec
    lda STORES
    sbc TEMP
    sta STORES
    lda STORES_H
    sbc TEMP_H
    sta STORES_H

    ; Aggiungi truppe (POP = POP + input originale salvato in IN_VAL)
    clc
    lda POP
    adc IN_VAL
    sta POP
    lda POP_H
    adc IN_VAL_H
    sta POP_H

    ; --- BATTAGLIA ---
    lda #<m_loc
    sta STR_PTR
    lda #>m_loc
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr PR_B_NAME

    lda #<m_btl
    sta STR_PTR
    lda #>m_btl
    sta STR_PTR_H
    jsr PRINT_STRING
    
    jsr WAIT_KEY
    cmp #ESC_KEY
    bne no_esc_loop
    jmp EXIT_TO_MENU
no_esc_loop:

    jsr EXEC_BATTLE
    
    inc B_ID
    lda B_ID
    cmp #7
    beq WIN_CW
    
    inc YEAR
    jmp MAIN_LOOP_CW

WIN_CW:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_win_cw
    sta STR_PTR
    lda #>msg_win_cw
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    jmp START

EXEC_BATTLE:
    jsr GET_RANDOM
    ; Perdite (Logica di base)
    lda #<m_loss
    sta STR_PTR
    lda #>m_loss
    sta STR_PTR_H
    jsr PRINT_STRING
    
    ; Sottrae 100 uomini per battaglia (esempio)
    lda #100
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16
    
    sec
    lda POP
    sbc #100
    sta POP
    lda POP_H
    sbc #0
    sta POP_H

    jsr GET_RANDOM
    cmp #$80
    bcc lost
    lda #<m_vic
    jmp p_res
lost:
    lda #<m_def
p_res:
    sta STR_PTR
    lda #>m_vic
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    rts

PR_B_NAME:
    lda B_ID
    asl a
    tax
    lda B_TBL,x
    sta STR_PTR
    lda B_TBL+1,x
    sta STR_PTR_H
    jsr PRINT_STRING
    rts

; ===================================================================
; TESTI E TABELLE
; ===================================================================

msg_intro_cw: 
    .byte 13, "  CIVIL WAR 1861", 13
    .byte "--------------------", 13
    .byte "LA NAZIONE E' DIVISA", 13
    .byte "COMANDA LE TRUPPE E", 13
    .byte "RIUNISCI GLI STATI.", 13
    .byte 13, "PREMI UN TASTO...", 0

msg_choose:    .byte 13, "SCEGLI PARTE:", 13, "1. NORD (GRANT)", 13, "2. SUD (LEE)", 13, 0
msg_win_cw:    .byte 13, "GUERRA FINITA!", 0

m_yr:    .byte 13, "ANNO: 18", 0
m_m:     .byte 13, "UOMINI: ", 0
m_g:     .byte 13, "ORO: ", 0
m_rec:   .byte 13, "ARRUOLA: ", 0
m_loc:   .byte 13, "LUOGO: ", 0
m_btl:   .byte 13, "COMBATTI!", 0
m_loss:  .byte 13, "CADUTI: ", 0

m_north: .byte 13, "UNIONE - GEN. GRANT", 0
m_south: .byte 13, "SUD - GEN. LEE", 0
m_vic:   .byte 13, "VITTORIA!", 0
m_def:   .byte 13, "SCONFITTA!", 0

B_TBL: .word b1, b2, b3, b4, b5, b6, b7
b1: .byte "FORT SUMTER", 0
b2: .byte "BULL RUN", 0
b3: .byte "SHILOH", 0
b4: .byte "ANTIETAM", 0
b5: .byte "GETTYSBURG", 0
b6: .byte "VICKSBURG", 0
b7: .byte "APPOMATTOX", 0
