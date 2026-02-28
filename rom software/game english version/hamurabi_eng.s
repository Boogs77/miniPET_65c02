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
    lda #90             ; Initial population: 90
    sta POP
    lda #0
    sta POP_H
    lda #$DC            ; Initial grain stores: 2780
    sta STORES
    lda #$0A
    sta STORES_H
    lda #$E8            ; Initial acres: 1000
    sta ACRES
    lda #$03
    sta ACRES_H
    lda #$55
    sta $4F             ; RNG seed        

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

    ; Random land price between 17 and 24
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

    ; --- Buy Acres ---
    lda #<msg_buy
    sta STR_PTR
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT 
    
    lda ACRES           ; Add purchased acres to total
    clc
    adc IN_VAL
    sta ACRES
    lda ACRES_H
    adc IN_VAL_H
    sta ACRES_H

    ; --- Feed the People ---
    lda #<msg_feed
    sta STR_PTR
    jsr PRINT_STRING
    jsr READ_INPUT_SILENT 

    lda STORES          ; Deduct grain used for food
    sec
    sbc IN_VAL
    sta STORES
    lda STORES_H
    sbc IN_VAL_H
    sta STORES_H
    bcs G_OK
    lda #0              ; Clamp to zero if underflow
    sta STORES
    sta STORES_H
G_OK:

    jsr CALC_FED        ; Calculate how many people were fed
    lda POP
    sec
    sbc TEMP
    sta TEMP_H          ; Number of people who starved
    bcs P_CHK
    lda #0
    sta TEMP_H
P_CHK:
    lda POP             ; Subtract starved population
    sec
    sbc TEMP_H
    sta POP
    lda POP_H
    sbc #0
    sta POP_H

    ; Harvest: gain acres * 3 grain
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

    ; Population growth: +10 people per year
    lda POP
    clc
    adc #10
    sta POP
    lda POP_H
    adc #0
    sta POP_H

    inc YEAR
    lda YEAR
    cmp #11             ; 10 years completed = game won
    beq J_WIN       
    
    lda POP_H
    bne NEXT_L
    lda POP
    cmp #5              ; Population below 5 = game lost
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

; --- Jump stubs (needed due to branch range limits) ---
J_WIN:  jmp WIN_L
J_LOSE: jmp LOSE_L

R_ESC:              
    pla             
    jmp HAMURABI_START
    jsr RESET_LCD


CALC_FED:
    ; Count how many people can be fed (20 grain feeds 1 person)
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

; --- TEXT STRINGS ---
msg_intro_hm:  .byte "--- HAMURABI ---", 13, "BABYLON AWAITS YOU", 13, "RULE FOR 10 YEARS", 13, 13, "ESC TO EXIT", 13, 0
msg_y:      .byte 13, "YEAR: ", 0
msg_p:      .byte 13, "PEOPLE: ", 0
msg_s:      .byte 13, "GRAIN: ", 0
msg_a:      .byte 13, "ACRES: ", 0
msg_pr:     .byte 13, "PRICE: ", 0
msg_buy:    .byte 13, "ACRES? ", 0
msg_feed:   .byte 13, "GRAIN FOR FOOD? ", 0
msg_ok:     .byte 13, 13, "TURN COMPLETE. ", 0
msg_lose:   .byte 13, "REVOLT! YOU HAVE", 13, "BEEN OVERTHROWN.", 0
msg_win:    .byte 13, "--- VICTORY! ---", 13, 13
            .byte "MAGNIFICENT! YOU", 13
            .byte "HAVE RULED WISELY", 13
            .byte "FOR 10 YEARS.", 13
            .byte "YOUR NAME WILL LIVE", 13
            .byte "IN HISTORY.", 13, 13, 0
