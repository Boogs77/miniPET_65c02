# 📑 Bill of Materials (BOM): miniPET 1.0

**Project:** miniPET
**Export Date:** 02/02/2026
**Source File:** `miniPET_final.sch`

---

### 🧠 Integrated Circuits (IC) & Logic
| Qty | Part | Value | Description | Package |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **U11** | 65C02 | 8-bit CMOS CPU | DIL40 |
| 2 | **U51, U61** | 65C22 | VIA (Versatile Interface Adapter) | DIL40 |
| 1 | **U43** | 65C51 | ACIA (Serial Interface) | DIL28 |
| 1 | **IC21** | HM62256 | Static RAM (SRAM) | DIL28-6 |
| 1 | **ZX1-28C256** | 228-1277-00-0602J | Zero Insertion Force (ZIF) Socket | 228-1277-00-0602J |
| 7 | **IC22, IC32, IC42, IC54, IC55, IC56, IC63** | 74AC138N | 3-to-8 Decoder/Demultiplexer | DIL16 |
| 4 | **IC23, IC24, IC33, IC34** | 74HC08N | Quad 2-input AND gate | DIL14 |
| 2 | **IC52, IC53** | 74HCT595N | 8-bit Shift Register with output latch | DIL16 |
| 1 | **IC41** | MAX232 | RS232 Transceiver | DIL16 |
| 1 | **IC12** | NE555 | General purpose bipolar Timer | DIL-08 |
| 1 | **IC13** | 74HCT04N | Hex INVERTER | DIL14 |
| 1 | **IC57** | 74HCT14N | Hex Schmitt Trigger Inverter | DIL14 |
| 1 | **IC25** | 74HCT00N | Quad 2-input NAND gate | DIL14 |

---

### ⚡ Resistors & Potentiometers
| Qty | Part | Value | Description | Package |
| :--- | :--- | :--- | :--- | :--- |
| 5 | **R14, R15, R16, R17, R18** | 3.3K | Standard Resistor | 0207/10 |
| 2 | **R1, R31** | 330 | Standard Resistor | 0207/10 |
| 2 | **R11, R41** | 1M | Standard Resistor | 0207/10 |
| 1 | **R12** | 47k | Standard Resistor | 0207/10 |
| 1 | **R13** | 1k | Standard Resistor | 0207/10 |
| 1 | **R51** | 15K | Standard Resistor | 0207/10 |
| 1 | **R62** | 220 | Standard Resistor | 0207/10 |
| 1 | **R61** | 10K | Potentiometer | PT-10 |

---

### 🔋 Capacitors
| Qty | Part | Value | Description | Package |
| :--- | :--- | :--- | :--- | :--- |
| 22 | **C11, C13-15, C21-25, C31-34, C46-48, C51-57, C61, C63** | 100n | Ceramic Capacitor (Decoupling) | C025-025X050 |
| 4 | **C41, C42, C43, C44** | 1u | Ceramic Capacitor | C050-025X075 |
| 1 | **C12** | 10uF | Polarized Capacitor | B45181A |
| 1 | **C45** | 20p | Ceramic Capacitor (for Crystal) | C025-025X050 |

---

### 💎 Diodes & Crystals
| Qty | Part | Value | Description | Package |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **Q41** | 1.8432MHz | Crystal | HC49/S |
| 1 | **QG1** | - | Crystal Oscillator | DIL14S |
| 3 | **D41, D51, D61** | BS140 / SB140 | Diode (Equiv. 1N4004) | DO41-10 |
| 1 | **D52** | 1N4148 | Fast Signal Diode | DO35-7 |
| 1 | **LED1** | RED | 5mm LED | LED5MM |

---

### 🔌 Connectors, Switches & Display
| Qty | Part | Value | Description | Package |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **LCD1** | DS-G160128STBWW | Graphic LCD | PAK100 |
| 1 | **J1** | POWER | DC Power Jack | SPC4078 |
| 1 | **X1** | RS232-DB9 | SUB-D 9-pin Connector | F09HP |
| 1 | **X2** | DIN 5 pin | Female DIN Connector | MAB5SH |
| 1 | **SW1** | MOMENTARY | Momentary Pushbutton (Reset) | TACTILE_RA |
| 11 | **JP1, JP11-13, JP2A-B, JP3A-D** | - | Jumper Headers | JP1 / JP2 / JP4 |

---