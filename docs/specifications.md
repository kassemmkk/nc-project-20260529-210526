# Device Specification — MSPM33C321A Derivative MCU

**Document ID:** SPEC-MSPM33C321A-DERIV-001
**Design Name:** `mspm33c321a_derivative`
**Version:** 1.0-draft
**Date:** 2026-05-29
**Status:** Draft — Stage 1 Requirements Output

---

## 1. Device Overview

The `mspm33c321a_derivative` is a cost-optimised derivative of the Texas Instruments MSPM33C321A microcontroller. It targets the same application space (industrial sensing, motor control, IoT edge nodes) while reducing non-volatile memory from 1 MB to 512 KB, increasing SRAM from 64 KB to 128 KB, removing one 12-bit ADC instance, and adding one I2C interface. All other subsystems, peripheral topology, clocking, and pinout strategy are carried forward from the reference device.

In the NC silicon toolchain the device is realised using a **RISC-V Hazard3** processor core (a functional Cortex-M0+ equivalent with SWD debug), the NC_SOCGEN AHB-Lite/APB fabric, and NC-qualified IP peripherals.

---

## 2. Key Specifications Summary

| Parameter | Specification |
|-----------|--------------|
| **CPU Core** | RISC-V Hazard3 RV32I (Cortex-M0+ functional equivalent) |
| **Debug** | 2-pin SWD |
| **CPU Clock** | Up to 80 MHz |
| **Program Memory** | 512 KB internal Flash (XIP) |
| **Data Memory** | 128 KB SRAM (4 × 32 KB compiled macro banks) |
| **Bus Architecture** | AHB-Lite (core bus) + 2 × APB bridge (peripheral bus) |
| **Package** | LQFP-64 (primary), VQFN-64 (alternate) |
| **GPIO** | 48 pins — GPIOA[15:0], GPIOB[15:0], GPIOC[15:0] |
| **UART** | 4 instances (UART0–UART3) |
| **SPI** | 2 instances (SPI0–SPI1) |
| **I2C** | 3 instances (I2C0–I2C2) ← +1 vs reference |
| **Timers** | 6 instances: 4 × GP 16-bit (TMR0–TMR3) + 2 × advanced (TMR4–TMR5) |
| **PWM** | 2 instances (PWM0–PWM1, derived from advanced timers) |
| **DMA** | 1 controller, 8 channels |
| **ADC** | 1 × 12-bit SAR ← −1 vs reference (mixed-signal block) |
| **AES** | 1 instance (AES-128/256) |
| **CRC** | 1 instance |
| **WWDT** | 1 windowed watchdog |
| **RTC** | 1 real-time clock with calendar |
| **SysTick** | 1 ARM-compatible SysTick timer |
| **Supply Voltage** | 1.8 V core (VCCD), 3.3 V IO (VDDIO) |
| **Temp Range** | −40 °C to +125 °C (industrial) |

---

## 3. Memory Map

| Region | Base Address | Size | Description |
|--------|-------------|------|-------------|
| Flash (XIP) | `0x0000_0000` | 512 KB (`0x0008_0000`) | Execute-in-place program flash |
| Reserved | `0x0008_0000` | — | Flash address space upper boundary |
| SRAM | `0x2000_0000` | 128 KB (`0x0002_0000`) | Data / stack / heap SRAM |
| APB Bus 0 | `0x4000_0000` | 64 KB (`0x0001_0000`) | Peripheral slots 0–15 (16 × 4 KB) |
| APB Bus 1 | `0x4001_0000` | 64 KB (`0x0001_0000`) | Peripheral slots 16–31 (16 × 4 KB) |
| Peripheral Region | `0x4000_0000` | — | All APB peripherals |

### 3.1 Peripheral Address Allocation (APB — illustrative, final offsets from NC_SOCGEN)

| Peripheral | Instance | APB Bus | APB Slot | Base Address (est.) |
|------------|----------|---------|----------|---------------------|
| GPIO | GPIOA | 0 | 0 | `0x4000_0000` |
| GPIO | GPIOB | 0 | 1 | `0x4000_1000` |
| GPIO | GPIOC | 0 | 2 | `0x4000_2000` |
| UART | UART0 | 0 | 3 | `0x4000_3000` |
| UART | UART1 | 0 | 4 | `0x4000_4000` |
| UART | UART2 | 0 | 5 | `0x4000_5000` |
| UART | UART3 | 0 | 6 | `0x4000_6000` |
| SPI | SPI0 | 0 | 7 | `0x4000_7000` |
| SPI | SPI1 | 0 | 8 | `0x4000_8000` |
| I2C | I2C0 | 0 | 9 | `0x4000_9000` |
| I2C | I2C1 | 0 | 10 | `0x4000_A000` |
| I2C | I2C2 | 0 | 11 | `0x4000_B000` |
| TMR | TMR0 | 0 | 12 | `0x4000_C000` |
| TMR | TMR1 | 0 | 13 | `0x4000_D000` |
| TMR | TMR2 | 0 | 14 | `0x4000_E000` |
| TMR | TMR3 | 0 | 15 | `0x4000_F000` |
| TMR | TMR4 | 1 | 0 | `0x4001_0000` |
| TMR | TMR5 | 1 | 1 | `0x4001_1000` |
| PWM | PWM0 | 1 | 2 | `0x4001_2000` |
| PWM | PWM1 | 1 | 3 | `0x4001_3000` |
| DMAC | DMAC0 | 1 | 4 | `0x4001_4000` |
| CRC | CRC0 | 1 | 5 | `0x4001_5000` |
| AES | AES0 | 1 | 6 | `0x4001_6000` |
| WWDT | WWDT0 | 1 | 7 | `0x4001_7000` |
| RTC | RTC0 | 1 | 8 | `0x4001_8000` |
| SysTick | SYSTICK0 | 1 | 9 | `0x4001_9000` |

> **Note:** Final base addresses are assigned by NC_SOCGEN during RTL generation; the table above is illustrative.

---

## 4. Interrupt Map (Estimated)

NC_SOCGEN auto-assigns interrupt vectors starting at IRQ0. The Hazard3 internal PLIC handles all peripheral interrupts. Below is the estimated IRQ assignment order:

| IRQ | Peripheral | Source |
|-----|-----------|--------|
| 0 | GPIOA | GPIO port A combined |
| 1 | GPIOB | GPIO port B combined |
| 2 | GPIOC | GPIO port C combined |
| 3 | UART0 | TX/RX/error |
| 4 | UART1 | TX/RX/error |
| 5 | UART2 | TX/RX/error |
| 6 | UART3 | TX/RX/error |
| 7 | SPI0 | TX/RX/done |
| 8 | SPI1 | TX/RX/done |
| 9 | I2C0 | Transfer complete/error |
| 10 | I2C1 | Transfer complete/error |
| 11 | I2C2 | Transfer complete/error (new instance) |
| 12 | TMR0 | Overflow/compare |
| 13 | TMR1 | Overflow/compare |
| 14 | TMR2 | Overflow/compare |
| 15 | TMR3 | Overflow/compare |
| 16 | TMR4 | Overflow/compare |
| 17 | TMR5 | Overflow/compare |
| 18 | PWM0 | Fault/period |
| 19 | PWM1 | Fault/period |
| 20 | DMAC0 | Channel done/error |
| 21 | CRC0 | Done |
| 22 | AES0 | Done |
| 23 | WWDT0 | Reset-warning / window-violation |
| 24 | RTC0 | Alarm/periodic |
| 25 | SYSTICK0 | SysTick underflow |

> **Derivative delta:** IRQ 11 (I2C2) is new vs. reference. ADC1 IRQ (previously assigned) is freed.

---

## 5. GPIO and Pinmux

### 5.1 GPIO Ports

| Port | Width | Reset Direction | Alternate Functions |
|------|-------|----------------|---------------------|
| GPIOA | 16 | Input (Hi-Z) | UART0/1 TX/RX, SPI0, I2C0/1, TMR0/1 |
| GPIOB | 16 | Input (Hi-Z) | UART2/3 TX/RX, SPI1, I2C2, TMR2/3 |
| GPIOC | 16 | Input (Hi-Z) | TMR4/5, PWM0/1, CAN (future), misc AF |

### 5.2 Pinmux Strategy
- Each GPIO pad has at least 4 alternate function (AF) slots managed by NC_GPIO AF matrix.
- UART, SPI, I2C, Timer, PWM outputs are exclusively assigned through pinmux; no dedicated IO pads.
- SWDCLK and SWDIO are dedicated pads (not GPIOs) wired directly to Hazard3 debug port.
- nRESET and CLK_IN are dedicated padframe pads.

---

## 6. Peripheral Specifications

### 6.1 UART (4 instances)
- Full-duplex asynchronous serial
- Baud rate: up to 5 Mbit/s at 80 MHz clock
- FIFO: 8-deep TX/FIFO (per NC_UART spec)
- Hardware flow control (RTS/CTS) via GPIO AF
- IrDA encoder/decoder support on UART0 (pinmux)
- IRQ: TX empty, RX ready, framing error, overrun

### 6.2 SPI (2 instances)
- Master/slave configurable
- Clock polarity (CPOL) and phase (CPHA) modes 0–3
- 8- or 16-bit data frames
- Up to 40 Mbit/s at 80 MHz
- Hardware NSS management

### 6.3 I2C (3 instances — I2C2 is derivative addition)
- Standard (100 kHz), Fast (400 kHz), Fast-Plus (1 MHz)
- 7-bit and 10-bit addressing
- Multi-master capable
- SMBus / PMBus compatible
- I2C2: identical spec to I2C0/I2C1; added to satisfy derivative requirement R-006

### 6.4 Timers (6 instances)
- **TMR0–TMR3:** 16-bit general-purpose, up/down/center-aligned count
- **TMR4–TMR5:** 16-bit advanced control (additional PWM channels, dead-time insertion)
- All timers: prescaler, capture, compare, input filter, IRQ on overflow/compare/capture

### 6.5 PWM (2 instances)
- Complementary output pairs with dead-time
- 16-bit resolution
- Fault input for motor control applications

### 6.6 DMA Controller (1 instance, 8 channels)
- Memory-to-memory, peripheral-to-memory, memory-to-peripheral
- Fixed / incrementing address modes
- Channel priority arbitration
- Transfer complete and error interrupts

### 6.7 AES (1 instance)
- AES-128 and AES-256
- ECB, CBC, CTR, GCM modes
- DMA-assisted bulk encryption

### 6.8 CRC (1 instance)
- CRC-8, CRC-16, CRC-32 polynomial selection
- Hardware acceleration, single-cycle result

### 6.9 WWDT (1 instance)
- Window lower/upper bounds configurable
- Early-warning interrupt before reset
- Independent clock domain (LFOSC or external)

### 6.10 RTC (1 instance)
- BCD calendar: seconds, minutes, hours, day, month, year
- Alarm A and Alarm B
- Periodic wakeup timer
- Backup domain retention through VDD brown-out

### 6.11 ADC — 1 × 12-bit SAR (mixed-signal block)
- **Note:** The second ADC instance from the MSPM33C321A reference is removed per R-005.
- The remaining ADC instance is a 12-bit successive-approximation converter.
- This block is realised at the mixed-signal / custom-cell level; it is outside the NC digital RTL framework.
- ADC integration signals (start-of-conversion, end-of-conversion, IRQ) connect to the digital APB bus via a thin digital wrapper to be specified at integration stage.
- Channels: 8 external (via GPIO analog mode), 2 internal (temperature sensor, VREF)

---

## 7. Clock Architecture

| Domain | Source | Frequency |
|--------|--------|-----------|
| CPU core | External crystal / PLL via MS_CLK_RST | Up to 80 MHz |
| AHB bus | Same as CPU core | Up to 80 MHz |
| APB peripherals | AHB / 2 divider | Up to 40 MHz |
| WWDT, RTC | Low-frequency oscillator (LFOSC ~32 kHz) | 32 kHz |
| SWD debug | Separate SWCLK pad | External |

---

## 8. Reset Architecture

| Reset Source | Type | Propagation |
|-------------|------|------------|
| External nRESET pad | Active-low, async assert | Full chip reset |
| Power-on reset (POR) | Internal | Full chip reset |
| Software reset (SYSRESETREQ) | CPU register | Core + peripheral reset |
| WWDT timeout | Watchdog expiry | Full chip reset |
| Brown-out detector | Undervoltage | Core reset (IO pads hold) |

---

## 9. Power Domains

| Domain | Rail | Nominal Voltage | Scope |
|--------|------|----------------|-------|
| VCCD | VDD | 1.8 V | CPU core, SRAM, bus fabric |
| VSSD | GND | 0 V | Core ground |
| VDDIO | VDDIO | 3.3 V | IO pads, GPIO output drivers |
| VSSIO | VSSIO | 0 V | IO ground |
| VDDA | VDDA | 3.3 V | ADC, VREF, analog blocks |
| VSSA | VSSA | 0 V | Analog ground |

---

## 10. Package

### 10.1 Primary: LQFP-64

| Parameter | Value |
|-----------|-------|
| Body | 10 mm × 10 mm |
| Lead count | 64 |
| Lead pitch | 0.5 mm |
| IO signal pads | 48 (GPIO × 3 ports) |
| Dedicated pads | 4 (nRESET, CLK_IN, SWDCLK, SWDIO) |
| Power pads | 8 (VDD×2, VSS×2, VDDIO×2, VDDA, VSSA) |
| Operating temp | −40 °C to +125 °C |

### 10.2 Alternate: VQFN-64

| Parameter | Value |
|-----------|-------|
| Body | 9 mm × 9 mm |
| Lead count | 64 |
| Exposed pad | 1 (thermal die-attach / VSS) |
| IO signal pads | 48 |
| Dedicated pads | 4 |
| Power pads | 8 |

---

## 11. Derivative Delta Summary

This section explicitly documents every change from the MSPM33C321A reference:

| Change | Reference | Derivative | Impact |
|--------|-----------|------------|--------|
| Flash (NVM) size | 1 MB | **512 KB** | Reduced XIP address window, smaller BOM cost |
| SRAM size | 64 KB | **128 KB** | Doubled data memory; upgraded for real-time applications |
| ADC instances | 2 × 12-bit SAR | **1 × 12-bit SAR** | ADC1 removed; frees IRQ vector; reduces die area |
| I2C instances | 2 | **3** | I2C2 added; new IRQ vector assigned; extra APB slot consumed |
| All other subsystems | Unchanged | Unchanged | Maintained for design continuity and pinout compatibility |

---

## 12. Compliance Notes

- The derivative RTL is generated using NC_SOCGEN with the `mspm33c321a_derivative` SoC configuration.
- RISC-V Hazard3 is an architectural functional equivalent of ARM Cortex-M0+ but is a distinct ISA implementation; end-user firmware requires recompilation for RISC-V (RV32I toolchain).
- ADC and analog blocks are outside the NC_SOCGEN digital generation scope and require separate mixed-signal integration.
- DFT (scan insertion, ATPG) is to be specified in the DFT change notes artifact (separate document).
