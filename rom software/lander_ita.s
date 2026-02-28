; ===================================================================
; LUNAR LANDER
; ===================================================================

; --- Zero Page ---
ALTITUDE    = $90   ; 16-bit
VELOCITY    = $92   ; 8-bit 
FUEL        = $93   ; 16-bit
LAST_BURN   = $95   ; Flame animation

START_LL:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda #<msg_intro_ll
    sta STR_PTR
    lda #>msg_intro_ll
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr WAIT_KEY
    
    cmp #ESC_KEY
    bne @no_exit        
    jmp EXIT_TO_MENU    
@no_exit:
    lda #0
    sta LAST_BURN
    jmp @init

@init:
    lda #<1000      
    sta ALTITUDE
    lda #>1000
    sta ALTITUDE+1
    lda #50         
    sta VELOCITY
    lda #<500       
    sta FUEL
    lda #>500
    sta FUEL+1

MAIN_LOOP_LL:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    
    ; --- GRAPHIC LOGICA 11 STEP ---
    lda #11
    sta TEMP_H          ; GRAPHICS WINDOWS 11 ROWS

    lda ALTITUDE
    sta IN_VAL
    lda ALTITUDE+1
    sta IN_VAL_H
    
    ldx #0              
@count_100:
    lda IN_VAL
    sec
    sbc #100
    sta IN_VAL
    lda IN_VAL_H
    sbc #0
    sta IN_VAL_H
    bcc @done_100
    inx
    cpx #10             ; VERTICAL SCALE ONLY 10 SPACES
    bne @count_100
@done_100:
    txa
    sta TEMP            
    lda #10             ; STARTER ROW CALC (0-10)
    sec
    sbc TEMP
    tax                 

@draw_loop:
    cpx #0
    beq @draw_ship_line
    lda #'|'            
    jsr CHROUT
    lda #$0D            
    jsr CHROUT
    dex
    dec TEMP_H
    bne @draw_loop

@draw_ship_line:
    lda #'|'            
    jsr CHROUT
    lda #' '            
    jsr CHROUT
    lda #'>'            
    jsr CHROUT
    lda #'#'
    jsr CHROUT
    lda #'<'
    jsr CHROUT
    
    lda LAST_BURN
    cmp #11             
    bcc @no_flames
    lda #$0D
    jsr CHROUT
    lda #'|'            
    jsr CHROUT
    lda #' '            
    jsr CHROUT
    lda #'^'            
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
@no_flames:
    lda #$0D
    jsr CHROUT
    dec TEMP_H

@draw_ground_line:      
    lda TEMP_H
    beq @draw_ground
    lda #'|'
    jsr CHROUT
    lda #$0D
    jsr CHROUT
    dec TEMP_H
    jmp @draw_ground_line

@draw_ground:
    lda #'='            
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT


    lda #<m_alt
    sta STR_PTR
    lda #>m_alt
    sta STR_PTR_H
    jsr PRINT_STRING
    lda ALTITUDE
    sta IN_VAL
    lda ALTITUDE+1
    sta IN_VAL_H
    jsr PRINT_NUM_16

    lda #<m_vel
    sta STR_PTR
    lda #>m_vel
    sta STR_PTR_H
    jsr PRINT_STRING
    lda VELOCITY
    sta IN_VAL
    lda #0
    sta IN_VAL_H
    jsr PRINT_NUM_16

    lda #<m_fuel
    sta STR_PTR
    lda #>m_fuel
    sta STR_PTR_H
    jsr PRINT_STRING
    lda FUEL
    sta IN_VAL
    lda FUEL+1
    sta IN_VAL_H
    jsr PRINT_NUM_16

    lda #<m_burn
    sta STR_PTR
    lda #>m_burn
    sta STR_PTR_H
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT
    
    lda IN_VAL
    sta LAST_BURN

    sec
    lda FUEL
    sbc IN_VAL
    sta FUEL
    lda FUEL+1
    sbc IN_VAL_H
    sta FUEL+1
    bcs @physics
    lda #0          
    sta FUEL
    sta FUEL+1
    sta LAST_BURN

@physics:
    lda VELOCITY
    clc
    adc #2          
    sta VELOCITY
    
    lda LAST_BURN
    lsr a           
    sta TEMP
    lda VELOCITY
    sec
    sbc TEMP
    bcs @v_pos
    lda #0          
@v_pos:
    sta VELOCITY

    sec
    lda ALTITUDE
    sbc VELOCITY
    sta ALTITUDE
    lda ALTITUDE+1
    sbc #0
    sta ALTITUDE+1

    jsr CHRIN
    cmp #ESC_KEY
    bne @check_landed
    jmp START_LL       

@check_landed:
    lda ALTITUDE+1
    bmi @landed     
    jmp MAIN_LOOP_LL

@landed:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda VELOCITY
    cmp #15         
    bcc @success
    
    lda #<msg_crash
    sta STR_PTR
    lda #>msg_crash
    sta STR_PTR_H
    jsr PRINT_STRING
    jmp @end_game

@success:
    lda #<msg_win_ll
    sta STR_PTR
    lda #>msg_win_ll
    sta STR_PTR_H
    jsr PRINT_STRING
    
    lda #<m_score
    sta STR_PTR
    lda #>m_score
    sta STR_PTR_H
    jsr PRINT_STRING
    lda FUEL
    sta IN_VAL
    lda FUEL+1
    sta IN_VAL_H
    jsr PRINT_NUM_16

@end_game:
    jsr WAIT_KEY
    jmp START_LL

; --- TESTI ---
msg_intro_ll: 
    .byte 13, "    LUNAR LANDER    ", 13
    .byte " ------------------ ", 13
    .byte "SPINTA > 10 => ^^^", 13
    .byte "VEL ATTERRAGGIO < 15", 13
    .byte "ESC PER USCIRE", 13, 0

m_alt:    .byte 13, "ALTITUDINE: ", 0
m_vel:    .byte 13, "VELOCITA' : ", 0
m_fuel:   .byte 13, "CARBURANTE: ", 0
m_burn:   .byte 13, "SPINTA: ", 0
m_score:  .byte 13, "PUNTEGGIO: ", 0
msg_crash: .byte 13, "CRASH!              SEI UN CRATERE.", 0
msg_win_ll: .byte 13, "ALLUNAGGIO RIUSCITO!", 0
