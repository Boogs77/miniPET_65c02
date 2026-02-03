# Boogs77-miniPET: 65C02-Based Retro Computer

![Main Photo](gallery/miniPET_image1.png)

The **Boogs77-miniPET** is a compact, high-performance 8-bit computer inspired by the iconic Commodore PET aesthetics. Built around the **W65C02S** processor, this project utilizes the modular architecture of the [BO6502 System](https://github.com/Boogs77/BO6502_65C02-based_modular_computer) and integrates it into a custom-designed, 3D-printed enclosure.

---

## 🧠 System Architecture & Modules

The internal logic of the miniPET is derived directly from the modular boards of the BO6502 project. Each core component follows the same electrical and logical specifications:

### ⚙️ Core Processing Unit (CPU, RAM, ROM)
The system's "brain" and memory management are based on the high-reliability design of the BO6502:
* **CPU:** Western Design Center **W65C02S**, allowing for modern high-speed operation while maintaining full 6502 compatibility.
* **Clock:** Switchable clock management (1MHz/2MHz) as defined in the [BO6502 Reset/Clock Module](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20RESET).
* **Memory Map:** * **RAM:** 32KB Static RAM ([BO6502 RAM](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20RAM)).
    * **ROM:** EEPROM-based storage for firmware and BASIC ([BO6502 ROM](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20ROM)).

### 📟 Display Interface (BIGLCD)
The visual output is handled by the **BIGLCD** module. 
* **Addressing:** The module is mapped and accessible at memory address **$D19X**.
* **Compatibility:** It uses the same Hitachi-compatible protocol as the [BO6502 BIGLCD](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20BIGLCD).

### ⌨️ Keyboard Input
Input is managed via a dedicated matrix keyboard interface.
* **Addressing:** The keyboard is mapped and accessible at memory address **$D18X**.
* **Reference:** [BO6502 KeyBoard Module](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20KEYb).

### 🔌 Serial Communication
Asynchronous communication is provided for external terminal access.
* **Addressing:** Accessible at the **$CXXX** memory range.
* **Reference:** Same implementation as the [BO6502 Serial Module](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20SERIAL).

---

## 🏗️ Enclosure & 3D Design

One of the most distinctive features of this project is its custom case. 

### Design Evolution
The enclosure is a professional modification of the original design found at [commodorepetmini.com](https://commodorepetmini.com/). Using **Autodesk Fusion 360**, the project was extensively modified to:
1.  Adapt the internal mounting pillars for the custom Boogs77 PCBs.
2.  Adjust the front bezel to fit the specific BIGLCD module dimensions.
3.  Optimize the structural integrity for modern FDM printing.

### Manufacturing
The case was manufactured in-house using an **Anycubic Kobra S1** 3D printer. The print settings were tuned for high detail to mimic the texture of the original 1970s hardware.

![Case Modification 1](gallery/miniPET_image6.png)
![Case Modification 2](gallery/miniPET_image7.png)

---

## 📋 Bill of Materials (BOM)

| Component | Description | Quantity |
| :--- | :--- | :--- |
| **W65C02S** | CMOS 8-bit Microprocessor | 1 |
| **AS6C62256** | 32K x 8 Static RAM | 1 |
| **AT28C256** | 32K x 8 EEPROM | 1 |
| **W65C22 (VIA)** | Versatile Interface Adapter | 2 |
| **NE555** | Precision Timer (Reset Circuit) | 1 |
| **BIGLCD** | High Contrast LCD Module | 1 |
| **3D Case** | Custom Fusion 360 Printed Parts | 1 set |
| **Passives** | Resistors, Capacitors, Sockets | 1 set |

---

## 🔗 Useful PCB Links

To replicate this build, the following PCB layouts are required:
* [Main System Logic (CPU/RAM/ROM)](https://github.com/Boogs77/Boogs77-miniPET_65c02/tree/main/eagle)
* [KeyBoard Matrix PCB](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20KEYb)
* [BIGLCD Interface PCB](https://github.com/Boogs77/BO6502_65C02-based_modular_computer/tree/main/BO6502%20BIGLCD)

---

## 🖼️ Project Gallery

Below are the photos showing the detailed realization and internal assembly of the miniPET.

![Assembly Stage 1](gallery/miniPET_image2.png)
![Assembly Stage 2](gallery/miniPET_image3.png)
![Assembly Stage 3](gallery/miniPET_image4.png)
![Assembly Stage 4](gallery/miniPET_image5.png)

---
*Created by Boogs77 - 2026*