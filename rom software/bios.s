.setcpu "65C02"
.debuginfo
.segment "BIOS"


ACIA_DATA	= $c000
ACIA_STATUS	= $c001
ACIA_CMD	= $c002
ACIA_CTRL	= $c003


LOAD:
                rts

SAVE:
                rts


MONRDKEY:
CHRIN:
                lda     ACIA_STATUS
                and     #$08
                beq     @no_keypressed_serial
                lda     ACIA_DATA
                jsr     CHROUT			; echo SERIAL OK
                sec
                rts
                
@no_keypressed_serial:
                lda kb_rptr
                cmp kb_wptr
                bne key_pressed
                lda IFR
                and #$02
                beq @no_keypressed_both
                jsr keyboard_interrupt
                jmp @no_keypressed_both

@no_keypressed_both:
                clc
                rts

key_pressed:

    phx                
    ldx kb_rptr
    lda kb_buffer, x
    inc kb_rptr
    
    pha
    lda PORTAK    
    pla

    and #$7F

    pha                 ; SAVE CHAR FOR COMPARING
    cmp #$0D            ; IS A RETURN?
    beq @skip_echo      
    
    pla                 ; LOAD FOR ECHO
    jsr CHROUT
    jmp @exit

@skip_echo:
    pla                 ; LOAD CR
@exit:
    plx                 
    sec
    rts


; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
MONCOUT:
CHROUT:
                pha
.ifdef BOOGS                
                jsr     print_lcd_ch
.endif

                sta     ACIA_DATA
                lda     #$FF
@txdelay:       dec
                bne     @txdelay
                pla
                rts

;; LOADING DRIVER
.include "serial_drv.s"
.include "biglcd_drv.s"
.include "keyboard_drv.s"
.include "boot_menu_multi.s"

; LOADING SOFTWARE
.include "games_lib.s"
.include "games.s"
.include "wozmon.s"






.segment "RESETVEC"
                .word   $0F00           ; NMI vector
                .word   SHOW_MENU       ; RESET vector
                .word   $0000           ; IRQ vector

