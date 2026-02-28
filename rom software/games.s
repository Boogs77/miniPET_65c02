.segment "GAMES"

HAMURABI:
  .include "hamurabi_ita.s"
    jmp SHOW_MENU
 
CIVILWAR:
  .include "civilwar_ita.s"
    jmp SHOW_MENU

BOWLING:
  .include "bowling_ita.s"
    jmp SHOW_MENU    

LUNARLANDER:
  .include "lander_ita.s"
    jmp SHOW_MENU  