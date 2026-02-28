# miniPET ROM Software

This document describes the source files that compose the firmware and game software burned into the **AT28C256 EEPROM** of the miniPET. All files are written in **65C02 assembly** and assembled with the **CA65** assembler (part of the cc65 toolchain).

The ROM is divided into two logical segments:
* **`BIOS`** — System firmware, hardware drivers, and boot environment (`$8000–$FFFF`)
* **`GAMES`** — Shared library, boot menu, and all game titles

`bios.s` is the assembly root: it pulls in all other modules via `.include` directives, producing a single binary image that is burned to the EEPROM.

---

## 🧱 Firmware Layer

### ⚙️ `bios.s` — BIOS Core
The foundation of the entire system. Defines all hardware memory-mapped addresses and implements the primary I/O entry points used throughout the firmware and games.

Key responsibilities:
* Hardware address constants: `ACIA_DATA/STATUS/CMD/CTRL` at `$C000–$C003` (serial), VIA registers for keyboard (`$D18X`) and LCD (`$D19X`)
* **`CHRIN`** / **`MONRDKEY`**: universal character input — polls the serial ACIA first, then falls back to the hardware keyboard circular buffer
* **`CHROUT`**: character output, mirrored to both serial terminal and LCD
* `LOAD` / `SAVE` stubs reserved for future expansion
* Acts as the include root, linking all driver and application modules into a single ROM image

### 🖥️ `biglcd_drv.s` — LCD Driver
Low-level driver for the **BIGLCD** module mapped at `$D19X`.

Key responsibilities:
* `INIT_LCD` / `RESET_LCD`: controller initialization and screen clear sequences
* Busy-wait byte write to the LCD data bus
* Character and string output helpers consumed by the BIOS and all game titles

### ⌨️ `keyboard_drv.s` — Keyboard Driver
Interrupt-driven driver for the matrix keyboard, interfaced via the W65C22 VIA at `$D18X`.

Key responsibilities:
* `INIT_KEYBOARD`: configures VIA port directions and enables the CB1 edge-triggered interrupt
* `keyboard_interrupt`: ISR that scans the matrix, decodes the keypress, and pushes the ASCII value into a circular ring buffer (`kb_buffer`)
* `FLUSH_KEYBOARD_HARD`: drains the keyboard buffer — called before every critical input prompt to discard stale keypresses
* `CHRIN_NO_ECHO`: reads a character without echoing it back to the terminal (used by the boot menu)

---

## 🚀 Boot & Environment Layer

### 🗂️ `boot_menu_multi.s` — Boot Menu
The interactive startup shell. Executed at power-on after hardware initialization, it presents a logo and a two-level menu over both the serial terminal and the LCD.

**Main Menu:**
| Key | Action |
| :---: | :--- |
| `1` | Launch **Woz Monitor** |
| `2` | Launch **MS BASIC** |
| `3` | Open **Games Sub-Menu** |

**Games Sub-Menu:**
| Key | Game |
| :---: | :--- |
| `1` | Hamurabi |
| `2` | Civil War 1861 |
| `3` | Bowling |
| `4` | Lunar Lander |
| `ESC` | Return to Main Menu |

All game selections are dispatched via `jmp` vectors to entry points defined in the game files. Any game can return to the sub-menu at any time by jumping to the global label `EXIT_TO_MENU`.

### 🔬 `wozmon.s` — Woz Monitor
The legendary **Apple 1** machine language monitor by Steve Wozniak, ported and adapted for the miniPET. Provides a low-level interface for memory inspection, direct editing, and machine code execution — the essential tool for any 6502 developer.

### 📝 `msbasic.s` — Microsoft BASIC
The classic 6502 port of **Microsoft BASIC**. Launched from the main menu (`key 2`) or directly from the Woz Monitor by executing at address `$8000`. Provides a full interactive BASIC interpreter for high-level programming.

---

## 🎮 Games Layer

### 📚 `games_lib.s` — Shared Games Library
A critical support module that must be included before any game file. Defines the shared zero-page layout and all common utility routines used by every game title.

**Zero-page allocations (shared across all games):**
| Address | Label | Description |
| :---: | :--- | :--- |
| `$20–$21` | `STR_PTR` / `STR_PTR_H` | 16-bit pointer for `PRINT_STRING` |
| `$40` | `YEAR` | Current year (Hamurabi, Civil War) |
| `$42–$44` | `POP_H`, `STORES`, `STORES_H` | Population and resource counters |
| `$4B–$4C` | `TEMP` / `TEMP_H` | General-purpose temporaries |
| `$4D–$4E` | `IN_VAL` / `IN_VAL_H` | 16-bit input/output value register |

**Key utility routines provided:**
* `PRINT_STRING` — prints a null-terminated string via pointer in `STR_PTR`
* `PRINT_NUM_16` — prints a 16-bit unsigned decimal number from `IN_VAL:IN_VAL_H`
* `READ_INPUT_SILENT` — reads a numeric value from the keyboard without echo, result in `IN_VAL`
* `WAIT_KEY` — blocks until any key is pressed
* `GET_RANDOM` — returns a pseudo-random byte in `A`
* `RESET_SERIAL_TERM` — sends ANSI escape codes to clear and home the terminal cursor
* `CLS` — issues VT100 screen-clear sequence

### 🎳 `bowling_ita.s` — Bowling
A 10-frame text-mode bowling simulator. Pins are represented as a 10-bit mask (`PINS_MASK` + `PINS_MASK_H`) and drawn as an ASCII triangle layout on the terminal. Each roll calls `EXEC_ROLL`, which iterates over all standing pins and uses `GET_RANDOM` to determine hits. Strike and Spare are detected by checking whether the pin mask reaches zero. Score accumulates across all 10 frames.

### ⚔️ `civilwar_ita.s` — Civil War 1861
A turn-based strategy game set during the American Civil War (1861–1865). The player chooses a side (Union or Confederacy) and manages troops and gold across 7 historical battles — from Fort Sumter to Appomattox. Each turn the player recruits soldiers (cost: 2 Gold per man), then fights a battle with random outcome. The battle location is looked up from the `B_TBL` word table. Victory or defeat is determined by a single random threshold comparison.

### 🎯 `hamurabi_ita.s` — Hamurabi
The classic resource management game set in ancient Babylon, inspired by the 1968 BASIC original. The player governs the city-state for 10 years, managing population (`POP`), grain stores (`STORES`), and farmland (`ACRES`). Each turn the player buys land, allocates grain for food, and harvests. The `CALC_FED` routine counts how many citizens can be fed (20 grain per person). If population drops below 5, the game ends in revolt; surviving 10 years triggers a victory screen.

### 🚀 `lander_ita.s` — Lunar Lander
A real-time physics simulation of a lunar descent. The lander begins at altitude 1000 with velocity 50 and fuel 500. Each turn, gravity adds 2 to velocity; the player inputs a thrust value which is halved and subtracted from velocity. Altitude decreases by velocity each tick. The graphical display shows an 11-row ASCII altimeter with the ship `>#<` positioned proportionally. Flames `^^^` are displayed below the ship when thrust exceeds 10. Landing is detected when altitude underflows to negative; a velocity below 15 constitutes a successful landing, scored by remaining fuel.

> ⚠️ **Known bug in `lander_ita.s`:** `ALTITUDE` is declared as 16-bit at `$90–$91`, but `VELOCITY` was incorrectly placed at `$91`, directly overlapping `ALTITUDE+1`. This caused altitude to increase rather than decrease as velocity was modified by gravity. **Fixed in the English version** by relocating variables: `VELOCITY=$92`, `FUEL=$93–$94`, `LAST_BURN=$95`.

---

## 🌐 English Version — `game english version/`

This subdirectory contains translated versions of all four game files, with all in-game strings, comments, and labels converted to English.

### Files included:
| Italian original | English version |
| :--- | :--- |
| `bowling_ita.s` | `bowling_eng.s` |
| `civilwar_ita.s` | `civilwar_eng.s` |
| `hamurabi_ita.s` | `hamurabi_eng.s` |
| `lander_ita.s` | `lander_eng.s` |

### Changes made for each file:

**`bowling_eng.s`**
* All `.byte` string literals translated: `"PRONTO?" → "READY?"`, `"LANCIO 1" → "ROLL 1"`, `"COLPITI" → "PINS HIT"`, `"PUNTEGGIO FINALE" → "FINAL SCORE"`, etc.
* All Italian comments translated to English throughout

**`civilwar_eng.s`**
* Intro screen text translated: `"LA NAZIONE E' DIVISA" → "THE NATION IS DIVIDED"`, `"PREMI UN TASTO" → "PRESS ANY KEY"`, etc.
* Status labels: `"UOMINI" → "MEN"`, `"ORO" → "GOLD"`, `"ARRUOLA" → "RECRUIT"`, `"LUOGO" → "LOCATION"`, `"CADUTI" → "CASUALTIES"`, `"VITTORIA" → "VICTORY"`, `"SCONFITTA" → "DEFEAT"`
* All Italian comments translated to English

**`hamurabi_eng.s`**
* Intro and result screens translated: `"BABILONIA TI ATTENDE" → "BABYLON AWAITS YOU"`, `"GOVERNA PER 10 ANNI" → "RULE FOR 10 YEARS"`, `"RIVOLTA! SEI STATO DEPOSTO" → "REVOLT! YOU HAVE BEEN OVERTHROWN"`, win screen fully rewritten in English
* Status labels: `"POPOLO" → "PEOPLE"`, `"GRANO" → "GRAIN"`, `"ACRI" → "ACRES"`, `"PREZZO" → "PRICE"`, `"TURNO CONCLUSO" → "TURN COMPLETE"`
* All Italian comments translated to English

**`lander_eng.s`**
* All display strings translated: `"ALTITUDINE" → "ALTITUDE"`, `"VELOCITA'" → "VELOCITY"`, `"CARBURANTE" → "FUEL"`, `"SPINTA" → "THRUST"`, `"PUNTEGGIO" → "SCORE"`, `"ALLUNAGGIO RIUSCITO" → "LANDING SUCCESSFUL"`, `"CRASH! SEI UN CRATERE" → "CRASH! YOU ARE A CRATER"`
* **Zero-page bug fixed**: `VELOCITY` moved from `$91` (collision with `ALTITUDE+1`) to `$92`; `FUEL` relocated to `$93–$94`; `LAST_BURN` to `$95`
* All Italian comments translated to English

### How to switch to the English version

To build the ROM with English games, update the `.include` directives in `bios.s` to reference the `_eng` variants instead of the `_ita` ones:

```asm
; Italian version (default)
.include "bowling_ita.s"
.include "civilwar_ita.s"
.include "hamurabi_ita.s"
.include "lander_ita.s"

; English version — replace with:
.include "game english version/bowling_eng.s"
.include "game english version/civilwar_eng.s"
.include "game english version/hamurabi_eng.s"
.include "game english version/lander_eng.s"
```

No other changes to `games_lib.s`, `boot_menu_multi.s`, or any driver file are required — all game entry points (`HAMURABI`, `CIVILWAR`, `BOWLING`, `LUNARLANDER`) and the `EXIT_TO_MENU` return vector remain identical between versions.

---

## 📁 Directory Structure

```
rom software/
├── bios.s                      # BIOS core & include root
├── biglcd_drv.s                # LCD controller driver
├── keyboard_drv.s              # Matrix keyboard interrupt driver
├── wozmon.s                    # Woz Monitor (Apple 1 port)
├── msbasic.s                   # Microsoft BASIC 6502
├── boot_menu_multi.s           # Two-level boot menu shell
├── games_lib.s                 # Shared zero-page layout & utility routines
├── games.s                     # Games segment include wrapper
├── bowling_ita.s               # Bowling (Italian)
├── civilwar_ita.s              # Civil War 1861 (Italian)
├── hamurabi_ita.s              # Hamurabi (Italian)
├── lander_ita.s                # Lunar Lander (Italian)
└── game english version/
    ├── bowling_eng.s           # Bowling (English)
    ├── civilwar_eng.s          # Civil War 1861 (English)
    ├── hamurabi_eng.s          # Hamurabi (English)
    └── lander_eng.s            # Lunar Lander (English + zero-page fix)
```

---
*Created by Boogs77 - 2026*
