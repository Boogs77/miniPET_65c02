.segment "GAMES"

HAMURABI:
  .include "hamurabi_eng.s"
    jmp SHOW_MENU
 
CIVILWAR:
  .include "civilwar_eng.s"
    jmp SHOW_MENU

BOWLING:
  .include "bowling_eng.s"
    jmp SHOW_MENU    

LUNARLANDER:
  .include "lander_eng.s"
    jmp SHOW_MENU  