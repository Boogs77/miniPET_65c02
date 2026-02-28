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
    lda #0              ; 0 = Union (North)
    sta SIDE
    jmp init_game
set_south:
    lda #1              ; 1 = Confederacy (South)
    sta SIDE

init_game:
    lda #61             ; Start year: 1861
    sta YEAR
    lda #0          
    sta B_ID            ; First battle index
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
    
    ; Annual income: +500 Gold per turn
    clc
    lda STORES
    adc #<500
    sta STORES
    lda STORES_H
    adc #>500
    sta STORES_H

    ; Display year
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

    ; Display men
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

    ; Display gold
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

    ; --- RECRUITMENT PHASE ---
    lda #<m_rec
    sta STR_PTR
    lda #>m_rec
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT 
    
    ; Cost = troops * 2 Gold (save input in TEMP for calculation)
    lda IN_VAL
    sta TEMP
    lda IN_VAL_H
    sta TEMP_H
    
    asl TEMP            ; Multiply by 2 (Gold cost)
    rol TEMP_H

    ; Deduct gold: STORES = STORES - TEMP
    sec
    lda STORES
    sbc TEMP
    sta STORES
    lda STORES_H
    sbc TEMP_H
    sta STORES_H

    ; Add troops: POP = POP + input (original value still in IN_VAL)
    clc
    lda POP
    adc IN_VAL
    sta POP
    lda POP_H
    adc IN_VAL_H
    sta POP_H

    ; --- BATTLE PHASE ---
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
    cmp #7              ; All 7 battles completed
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
    ; Battle casualties (basic logic)
    lda #<m_loss
    sta STR_PTR
    lda #>m_loss
    sta STR_PTR_H
    jsr PRINT_STRING
    
    ; Fixed loss of 100 men per battle
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
    cmp #$80            ; 50% chance of victory
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
    asl a               ; Multiply index by 2 for word table lookup
    tax
    lda B_TBL,x
    sta STR_PTR
    lda B_TBL+1,x
    sta STR_PTR_H
    jsr PRINT_STRING
    rts

; ===================================================================
; STRINGS AND TABLES
; ===================================================================

msg_intro_cw: 
    .byte 13, "  CIVIL WAR 1861", 13
    .byte "--------------------", 13
    .byte "THE NATION IS DIVIDED", 13
    .byte "COMMAND YOUR TROOPS", 13
    .byte "AND REUNITE THE STATES.", 13
    .byte 13, "PRESS ANY KEY...", 0

msg_choose:    .byte 13, "CHOOSE SIDE:", 13, "1. NORTH (GRANT)", 13, "2. SOUTH (LEE)", 13, 0
msg_win_cw:    .byte 13, "WAR IS OVER!", 0

m_yr:    .byte 13, "YEAR: 18", 0
m_m:     .byte 13, "MEN: ", 0
m_g:     .byte 13, "GOLD: ", 0
m_rec:   .byte 13, "RECRUIT: ", 0
m_loc:   .byte 13, "LOCATION: ", 0
m_btl:   .byte 13, "FIGHT!", 0
m_loss:  .byte 13, "CASUALTIES: ", 0

m_north: .byte 13, "UNION - GEN. GRANT", 0
m_south: .byte 13, "SOUTH - GEN. LEE", 0
m_vic:   .byte 13, "VICTORY!", 0
m_def:   .byte 13, "DEFEAT!", 0

B_TBL: .word b1, b2, b3, b4, b5, b6, b7
b1: .byte "FORT SUMTER", 0
b2: .byte "BULL RUN", 0
b3: .byte "SHILOH", 0
b4: .byte "ANTIETAM", 0
b5: .byte "GETTYSBURG", 0
b6: .byte "VICKSBURG", 0
b7: .byte "APPOMATTOX", 0
