.segment "CODE"

INIT_SERIAL:
                CLD                     ; Clear decimal arithmetic mode.
                CLI
                LDA     #$1F            ; 8-N-1, 19200 bps
                STA     ACIA_CTRL
                LDY     #$8B            ; No parity, no echo, no interrupts.
                STY     ACIA_CMD

                RTS