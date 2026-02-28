.segment "CODE"
.define BIOS_VER "28.02.26"

SHOW_MENU:
    jsr FLUSH_KEYBOARD_HARD
    JSR INIT_SERIAL           ; from serial_drv
    JSR INIT_KEYBOARD 
    jsr INIT_LCD              ; from keyboard_drv
    jsr RESET_SERIAL_TERM     ; Send ANSI codes to clear terminal     
    ldx #$00
    txs
    jsr RESET_LCD
    jsr print_boot_menu       ; Display Logo and Main Menu options

wait_key_main:
    jsr CHRIN_NO_ECHO         ; Call BIOS character input
    bcc wait_key_main         ; Carry clear means no key, keep checking
    
    cmp #'1'            
    beq go_woz                ; '1' -> Jump to Woz Monitor
    cmp #'2'            
    beq go_basic              ; '2' -> Jump to MS BASIC
    cmp #'3'            
    beq go_program            ; '3' -> Open Games Menu
    cmp #'4'            
    beq go_info               ; '4' -> Open System Info
    jmp wait_key_main         ; Ignore other keys

go_woz:
    jsr FLUSH_KEYBOARD_HARD  
    jsr RESET_SERIAL_TERM
    jsr INIT_LCD
    jmp RESET           

go_basic:
    jsr FLUSH_KEYBOARD_HARD  
    jsr RESET_SERIAL_TERM
    jsr INIT_LCD
    jmp $8000           

; --- System Information Page ---
go_info:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr INIT_LCD
    pha                       ; Save Accumulator to stack
    phx                       ; Save X to stack
    phy                       ; Save Y to stack (65C02 instruction)
    ldx #0
info_loop:
    lda sys_info_text, x      
    beq info_wait             ; If null terminator, stop printing
    jsr CHROUT                ; Print character
    inx
    jmp info_loop
info_wait:
    jsr CHRIN_NO_ECHO            
    bcc info_wait             ; Wait for any keypress
    ply                       ; Restore Y from stack
    plx                       ; Restore X from stack
    pla                       ; Restore A from stack
SHORT_JUMP:    
    jmp SHOW_MENU             ; Return to main menu

; --- Games Submenu ---
go_program:
    jsr FLUSH_KEYBOARD_HARD
    jsr RESET_SERIAL_TERM
    jsr INIT_LCD
    jsr print_basic_menu      
game_wait:
    jsr CHRIN_NO_ECHO          
    bcc game_wait       
    cmp #'1'            
    beq do_hamurabi
    cmp #'2'            
    beq do_civilwar
    cmp #'3'            
    beq do_bowling
    cmp #'4'            
    beq do_lander 
    cmp #$1B                  ; Check for ESC key (ASCII 27)
    beq SHORT_JUMP            ; Go back to main menu
    jmp game_wait

; Jump vectors for games (Placeholders)
do_hamurabi: jsr FLUSH_KEYBOARD_HARD
             jsr RESET_SERIAL_TERM
             jmp HAMURABI
do_civilwar: jsr FLUSH_KEYBOARD_HARD
             jsr RESET_SERIAL_TERM
             jmp CIVILWAR
do_bowling:  jsr FLUSH_KEYBOARD_HARD
             jsr RESET_SERIAL_TERM
             jmp BOWLING 
do_lander:   jsr FLUSH_KEYBOARD_HARD
             jsr RESET_SERIAL_TERM
             jmp LUNARLANDER 

; --- Print Routines (Full Stack Protection) ---

print_boot_menu:
    pha
    phx
    phy
    jsr print_logo
    ldx #0
main_loop:
    lda menu_text, x
    beq main_exit
    jsr CHROUT
    inx
    jmp main_loop
main_exit:
    jsr print_version
    ply
    plx
    pla
    rts

print_basic_menu:
    pha
    phx
    phy
    jsr print_logo
    ldx #0
game_menu_loop:
    lda basic_menu_text, x
    beq game_menu_exit
    jsr CHROUT
    inx
    jmp game_menu_loop
game_menu_exit:
    jsr print_version
    ply
    plx
    pla
    rts

print_logo:
    pha
    phx
    phy
    ldx #0
logo_loop:
    lda logo_art, x
    beq logo_exit
    jsr CHROUT
    inx
    jmp logo_loop
logo_exit:
    ply
    plx
    pla
    rts

print_version:
    pha
    phx
    phy
    ldx #0
version_loop:
    lda bios_footer, x
    beq version_exit
    jsr CHROUT
    inx
    jmp version_loop
version_exit:
    ply
    plx
    pla
    rts

; --- Serial Terminal ANSI Reset ---
RESET_SERIAL_TERM:
    pha
    lda #$1B        ; ESC character
    jsr CHROUT
    lda #'['
    jsr CHROUT
    lda #'2'
    jsr CHROUT
    lda #'J'        ; Clear Screen command
    jsr CHROUT
    lda #$1B
    jsr CHROUT
    lda #'['
    jsr CHROUT
    lda #'H'        ; Move Cursor to Home (1,1)
    jsr CHROUT
    pla
    rts

CHRIN_NO_ECHO:
    ; Controlla seriale
    lda     ACIA_STATUS
    and     #$08
    beq     @check_keyboard
    lda     ACIA_DATA
    sec
    rts

@check_keyboard:
    lda     IFR
    and     #$02
    beq     @check_buffer
    jsr     keyboard_interrupt
    lda     #%00000010
    sta     IFR                   ; clear CA1

@check_buffer:
    lda     kb_rptr
    cmp     kb_wptr
    beq     @no_key
    ldx     kb_rptr
    lda     kb_buffer, x
    inc     kb_rptr
    sec
    rts

@no_key:
    clc
    rts

FLUSH_KEYBOARD_HARD:
    pha
    phx
    phy
    
   lda kb_wptr
   sta kb_rptr
   
    ldx #$FF
@delay1:
    ldy #$FF
@delay2:
    dey
    bne @delay2
    dex
    bne @delay1
    
    ; Flush 2 
    lda kb_wptr
    sta kb_rptr
    
    ; Clear interrupt flag
    lda #%00000010
    sta IFR
    
    ply
    plx
    pla
    rts




; --- Data Section (Strings) ---

logo_art:
    .byte " ",$0D, $0A
    .byte "   --- mini ---     ", $0A;$0D, $0A
    .byte "  ___  ____  ____   ", $0A;$0D, $0A
    .byte " | _ \| ___||_  _|  ", $0A;$0D, $0A
    .byte " |  _/| _|    | |   ", $0A;$0D, $0A
    .byte " |_|  |____|  |_|   ", $0A;$0D, $0A
    .byte "--------------------", $0A, $00 ;$0D, $0A, $00

menu_text:
    .byte " ",$0D, $0A
    .byte " 1. WOZ MONITOR", $0D, $0A
    .byte " 2. MS BASIC", $0D, $0A
    .byte " 3. GAMES", $0D, $0A
    .byte " 4. SYSTEM INFO", $0D, $0A, 0

basic_menu_text:
    .byte " ",$0D, $0A
    .byte " 1. HAMURABI", $0D, $0A
    .byte " 2. CIVIL WAR", $0D, $0A
    .byte " 3. BOWLING", $0D, $0A
    .byte " 4. LUNAR LANDER", $0D, $0A, 0



sys_info_text:
    .byte " ",$0D, $0A
    .byte "--- SYSTEM INFO ---", $0D, $0A
    .byte " ",$0D, $0A
    .byte "CPU:W65C02S @1MHz"  , $0D, $0A
    .byte "RAM:32KB $0000-7FFF", $0D, $0A
    .byte "ROM:32KB $8000-FFFF", $0D, $0A
    .byte "SER:6551      @C000", $0D, $0A
    .byte "KYB:6522      @D180", $0D, $0A
    .byte "LCD:160x128   @D190", $0D, $0A
    .byte "PWR:5V DC REGULATED", $0D, $0A
    .byte "VER:", BIOS_VER , $0D, $0A;, $0A
    .byte "OS :WozMon", $0D, $0A
    .byte " ",$0D, $0A
    .byte "--------------------", $0A
    .byte "Press any key...    ", 0


bios_footer:
    .byte $0D, $0A
    .byte "____________________", $0A
    .byte "BIOS Ver. ", BIOS_VER, $0D, $0A
    .byte "Select > ", 0
 