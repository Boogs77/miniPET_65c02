; ===================================================================
; LUNAR LANDER
; ===================================================================

; --- Zero Page ---
; NOTE: ALTITUDE is 16-bit and occupies $90 and $91.
;       VELOCITY must NOT overlap with ALTITUDE+1.
;       Fix: move VELOCITY to $92, FUEL to $93, LAST_BURN to $95.
ALTITUDE    = $90   ; 16-bit (low=$90, high=$91)
VELOCITY    = $92   ; 8-bit  (was $91 — overlapped ALTITUDE+1!)
FUEL        = $93   ; 16-bit (low=$93, high=$94)
LAST_BURN   = $95   ; Used for flame animation

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
    lda #<1000          ; Initial altitude: 1000
    sta ALTITUDE
    lda #>1000
    sta ALTITUDE+1
    lda #50             ; Initial descent velocity: 50
    sta VELOCITY
    lda #<500           ; Initial fuel: 500
    sta FUEL
    lda #>500
    sta FUEL+1

MAIN_LOOP_LL:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    
    ; --- GRAPHICS: 11-step altitude scale ---
    lda #11
    sta TEMP_H          ; Total graphic window: 11 rows

    lda ALTITUDE
    sta IN_VAL
    lda ALTITUDE+1
    sta IN_VAL_H
    
    ; Count how many 100-unit segments the altitude covers (max 10)
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
    cpx #10             ; Cap at 10 segments above ground
    bne @count_100
@done_100:
    txa
    sta TEMP            
    lda #10             ; Calculate starting row (0–10)
    sec
    sbc TEMP
    tax                 

@draw_loop:
    cpx #0
    beq @draw_ship_line
    lda #'|'            ; Empty sky row
    jsr CHROUT
    lda #$0D            
    jsr CHROUT
    dex
    dec TEMP_H
    bne @draw_loop

@draw_ship_line:
    lda #'|'            ; Left border
    jsr CHROUT
    lda #' '            
    jsr CHROUT
    lda #'>'            ; Ship body
    jsr CHROUT
    lda #'#'
    jsr CHROUT
    lda #'<'
    jsr CHROUT
    
    lda LAST_BURN
    cmp #11             ; Show flames if thrust > 10
    bcc @no_flames
    lda #$0D
    jsr CHROUT
    lda #'|'            ; Left border for flame row
    jsr CHROUT
    lda #' '            
    jsr CHROUT
    lda #'^'            ; Flame characters
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
    lda #'='            ; Ground line
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT
    jsr CHROUT

    ; --- STATUS DISPLAY ---
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

    ; --- PHYSICS ---
    ; Deduct fuel (clamped to zero if not enough)
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
    sta LAST_BURN       ; No thrust if out of fuel

@physics:
    ; Apply gravity: velocity increases by 2 each turn
    lda VELOCITY
    clc
    adc #2          
    sta VELOCITY
    
    ; Apply thrust: halve burn value and subtract from velocity
    lda LAST_BURN
    lsr a           
    sta TEMP
    lda VELOCITY
    sec
    sbc TEMP
    bcs @v_pos
    lda #0          ; Clamp velocity to zero (can't go negative)
@v_pos:
    sta VELOCITY

    ; Update altitude: subtract velocity
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
    jmp START_LL        ; ESC restarts the game
    
@check_landed:
    lda ALTITUDE+1
    bmi @landed         ; Altitude went negative (underflow) = landed
    jmp MAIN_LOOP_LL

@landed:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr RESET_LCD
    lda VELOCITY
    cmp #15             ; Landing velocity under 15 = safe landing
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
    jsr PRINT_NUM_16    ; Score = remaining fuel

@end_game:
    jsr WAIT_KEY
    jmp START_LL

; --- STRINGS ---
msg_intro_ll: 
    .byte 13, "    LUNAR LANDER    ", 13
    .byte " ------------------ ", 13
    .byte "THRUST > 10 => ^^^", 13
    .byte "LANDING VEL < 15", 13
    .byte "ESC TO EXIT", 13, 0

m_alt:    .byte 13, "ALTITUDE : ", 0
m_vel:    .byte 13, "VELOCITY : ", 0
m_fuel:   .byte 13, "FUEL     : ", 0
m_burn:   .byte 13, "THRUST   : ", 0
m_score:  .byte 13, "SCORE    : ", 0
msg_crash:  .byte 13, "CRASH!              YOU ARE A CRATER.", 0
msg_win_ll: .byte 13, "LANDING SUCCESSFUL!", 0
