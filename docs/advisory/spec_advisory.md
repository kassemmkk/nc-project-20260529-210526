# MCU Factory Spec Advisory — Raw Output

**Advisory Registry Name:** `Spec Advisory`
**Advisory ID:** `4b20feaa-fec6-4260-a356-871298ba6d20`
**Advisory Type:** spec
**Purpose:** Produce Golden Micro-Arch Spec from user request

> **Name Resolution Note:** The workflow requested exact name `MCU Factory Spec Advisory`.
> The advisory registry does not contain that exact name. The advisory named `Spec Advisory`
> (type: `spec`, purpose: "Produce Golden Micro-Arch Spec from user request") was identified
> as the functional match and executed. The output below is the authoritative Golden Spec.
> Advisory ID used: `4b20feaa-fec6-4260-a356-871298ba6d20`.

**Input submitted to advisory:**
- User brief: MSPM33C321A Derivative MCU (`docs/user_brief.md`)
- Resolved requirements table (26 requirements, R-001 through D-011)
- SoC config field mapping (`config/soc_config.yaml`)
- Padframe requirement summary (`docs/padframe_requirements.md`)

**Date:** 2026-05-29

---

## Raw Advisory Output

As Chairperson of the Architecture Advisory, I have reviewed the submitted proposals and the peer rankings. The critical requirement to use the `Hazard3 RISC-V` core, as explicitly defined in the resolved requirements (R-001, D-001), was missed by one proposal, which is a disqualifying error. The other proposal correctly identified this core architecture and provided a superior structural foundation.

By synthesizing the correct architectural foundation from the second proposal with the detailed interface specifications, constraints, and structural clarity of the first, we can create a definitive Golden Specification. This synthesized document resolves all ambiguities and incorporates the strongest elements from all inputs. It is now ready for the RTL design and verification teams.

---

## Golden Micro-Architecture Specification: mspm33c321a_derivative

| Document ID     | `uArch-mspm33c321a_deriv-v1.0-GOLDEN` |
|-----------------|---------------------------------|
| **Project Name**| `mspm33c321a_derivative`        |
| **Version**     | 1.0                             |
| **Status**      | **RELEASED FOR IMPLEMENTATION** |
| **Description** | Defines the micro-architecture for a cost-reduced/enhanced derivative of the TI MSPM33C321A. This document is the single source of truth for RTL design and verification, superseding all prior proposals. |

---

### 1. Architecture Overview and Functional Block Diagram

The `mspm33c321a_derivative` is an MCU System-on-Chip (SoC) featuring a `hazard3` RISC-V core. The architecture is based on an AHB-Lite bus fabric connecting the high-speed CPU, memories, and DMA to two APB buses for lower-bandwidth peripherals.

**Key Architectural Features & Derivative Changes:**
*   **CPU Core:** `hazard3_2port_swd` (RV32I) RISC-V core @ 80 MHz with an integrated Platform-Level Interrupt Controller (PLIC).
*   **Flash (NVM):** Reduced to **512 KB** via an external XIP interface.
*   **SRAM:** Increased to **128 KB**, implemented as 4x32KB physical blocks.
*   **ADC:** Reduced to a single **1x 12-bit SAR** instance (ADC1 logic and IRQ removed).
*   **I2C:** Increased to **3 instances** (I2C2 added).
*   **Interconnect:** A single AHB-Lite master/decoder fabric with two APB subordinate buses.
*   **Package:** Pin-compatible LQFP-64.

```mermaid
graph TD
    subgraph mspm33c321a_derivative_compute_ss
        subgraph CPU Subsystem
            CPU[hazard3_2port_swd<br/>RISC-V RV32I @ 80 MHz<br/>Internal PLIC (32 IRQs)];
            SWD_IF[SWD Debug Port];
            CPU -- Debug --> SWD_IF;
        end

        subgraph Memory Subsystem
            XIP[XIP Controller<br/>512 KB Flash<br/>@ 0x0000_0000];
            SRAM[SRAM Controller<br/>128 KB (4x32KB)<br/>@ 0x2000_0000];
        end

        subgraph AHB-Lite Fabric (32-bit)
            direction LR
            AHB_BUS[AHB-Lite Bus Fabric];
            DMAC[DMA Controller<br/>8 Channels];
            A2P_0[AHB-to-APB Bridge 0];
            A2P_1[AHB-to-APB Bridge 1];
        end

        subgraph APB0_Peripherals [APB Bus 0 @ 0x4000_0000]
            direction TB
            APB0_BUS[APB0 Bus (16 Slots)];
            SYS_CTRL[SYS_CTRL];
            GPIOs[GPIO A, B, C];
            COMMS[UARTs 0-3, SPIs 0-1, I2Cs 0-2];
            TIMERS_GP[GP Timers 0-2];
        end

        subgraph APB1_Peripherals [APB Bus 1 @ 0x4001_0000]
            direction TB
            APB1_BUS[APB1 Bus (10 Slots)];
            TIMERS_ADV[GP Timer 3, Adv Timers 4-5];
            ACCEL[CRC, AES];
            SYSTEM[WWDT, RTC, SysTick, ADC0 Ctrl];
        end

        CPU -- I-Bus/D-Bus --> AHB_BUS;
        AHB_BUS --- XIP;
        AHB_BUS --- SRAM;
        AHB_BUS --- DMAC;
        AHB_BUS --- A2P_0;
        AHB_BUS --- A2P_1;

        A2P_0 --> APB0_BUS;
        APB0_BUS --> SYS_CTRL & GPIOs & COMMS & TIMERS_GP;

        A2P_1 --> APB1_BUS;
        APB1_BUS --> TIMERS_ADV & ACCEL & SYSTEM;
    end
```

---

### 2. System Addressing & Memory Map

The SoC utilizes a 32-bit address space. All registers are 32-bit and accessed on 32-bit boundaries.

#### 2.1. Global Memory Map

| Region | Base Address | End Address | Size | Description |
|---|---|---|---|---|
| Flash (XIP) | `0x0000_0000` | `0x0007_FFFF` | 512 KB | Execute-In-Place Non-Volatile Memory |
| SRAM | `0x2000_0000` | `0x2001_FFFF` | 128 KB | Main System RAM (4 x 32 KB physical macros) |
| APB Bus 0 | `0x4000_0000` | `0x4000_FFFF` | 64 KB | GPIO, Comms, and General System Peripherals |
| APB Bus 1 | `0x4001_0000` | `0x4001_FFFF` | 64 KB | Advanced Timers, Accelerators, and Subsystem Peripherals |
| Private Bus | `0xE000_0000` | `0xE00F_FFFF` | 1 MB | Core-private peripherals (e.g., PLIC, SysTick) |

---

### 3. Detailed Peripheral Register Map

Each peripheral is allocated a 4 KB address space (`0x1000` bytes). All unspecified register bits are reserved and shall read as '0' and be written with '0'.

#### 3.1. APB Bus 0 Peripheral Map (Base: `0x4000_0000`)

| Slot | Address Offset | Base Address | IRQ | Peripheral | Notes |
|:----:|:---:|:---:|:---:|---|---|
| 0 | `0x0000` | `0x4000_0000` | - | **SYS_CTRL** | System Config (Pin Mux, Peripheral Clock Gating, etc.) |
| 1 | `0x1000` | `0x4000_1000` | 0 | GPIOA | GPIO Port A (16 pins) |
| 2 | `0x2000` | `0x4000_2000` | 1 | GPIOB | GPIO Port B (16 pins) |
| 3 | `0x3000` | `0x4000_3000` | 2 | GPIOC | GPIO Port C (16 pins) |
| 4 | `0x4000` | `0x4000_4000` | 3 | UART0 | |
| 5 | `0x5000` | `0x4000_5000` | 4 | UART1 | |
| 6 | `0x6000` | `0x4000_6000` | 5 | UART2 | |
| 7 | `0x7000` | `0x4000_7000` | 6 | UART3 | |
| 8 | `0x8000` | `0x4000_8000` | 7 | SPI0 | |
| 9 | `0x9000` | `0x4000_9000` | 8 | SPI1 | |
| 10 | `0xA000` | `0x4000_A000` | 9 | I2C0 | |
| 11 | `0xB000` | `0x4000_B000` | 10 | I2C1 | |
| 12 | `0xC000` | `0x4000_C000` | 11 | **I2C2** | **Derivative Addition** |
| 13 | `0xD000` | `0x4000_D000` | 12 | TMR0 (GP) | 16-bit General Purpose Timer |
| 14 | `0xE000` | `0x4000_E000` | 13 | TMR1 (GP) | 16-bit General Purpose Timer |
| 15 | `0xF000` | `0x4000_F000` | 14 | TMR2 (GP) | 16-bit General Purpose Timer |

#### 3.2. APB Bus 1 Peripheral Map (Base: `0x4001_0000`)

| Slot | Address Offset | Base Address | IRQ | Peripheral | Notes |
|:----:|:---:|:---:|:---:|---|---|
| 0 | `0x0000` | `0x4001_0000` | 15 | TMR3 (GP) | 16-bit General Purpose Timer |
| 1 | `0x1000` | `0x4001_1000` | 16 | TMR4 (Advanced) | 16-bit Advanced Timer (PWM Capable) |
| 2 | `0x2000` | `0x4001_2000` | 17 | TMR5 (Advanced) | 16-bit Advanced Timer (PWM Capable) |
| 3 | `0x3000` | `0x4001_3000` | 18 | PWM0 | Software alias for TMR4 |
| 4 | `0x4000` | `0x4001_4000` | 19 | PWM1 | Software alias for TMR5 |
| 5 | `0x5000` | `0x4001_5000` | 20 | DMAC0 | 8-channel DMA Controller |
| 6 | `0x6000` | `0x4001_6000` | 21 | CRC0 | CRC Accelerator |
| 7 | `0x7000` | `0x4001_7000` | 22 | AES0 | AES-128/256 Accelerator |
| 8 | `0x8000` | `0x4001_8000` | 23 | WWDT0 | Windowed Watchdog Timer |
| 9 | `0x9000` | `0x4001_9000` | 24 | RTC0 | Real-Time Clock with Calendar |
| 10 | `0xA000` | `0x4001_A000` | 25 | SysTick | System Tick Timer |
| 11 | `0xB000` | `0x4001_B000` | (ANA) | ADC0 | Digital Control Interface for 12-bit SAR ADC |

---

### 4. Interface Specifications

#### 4.1. Physical Pads & Packaging

*   **Package:** LQFP-64 (10mm x 10mm, 0.5mm pitch).
*   **Total Pads:** 64
    *   **GPIO signal pads:** 48 (organized as Port A, B, C of 16 pins each).
    *   **Dedicated pads:** 4 (nRESET, CLK_IN, SWDCLK, SWDIO).
    *   **Power/Ground pads:** 10 (VDD, VSS, VDDIO, VSSIO, VDDA, VSSA).
    *   **Corner/No-Connect:** 2.
*   **Reset (nRESET):** Active-low, Schmitt-trigger input with an internal 10kΩ pull-up.
*   **Clock (CLK_IN):** Low-jitter analog input cell for 4-80 MHz crystal or oscillator.
*   **Debug (SWD):** SWDCLK is a buffered input. SWDIO is a tri-state I/O with a weak internal pull-up.

#### 4.2. Electrical & Timing Characteristics

*   **Clock (CLK_IN):**
    *   Frequency: 4-80 MHz
    *   Duty Cycle: 45-55%
    *   Jitter: <100ps RMS
*   **Reset (nRESET):**
    *   Assertion: Asynchronous
    *   Deassertion: Synchronous to system clock
    *   Minimum Pulse Width: 100ns
*   **GPIO (3.3V Domain):**
    *   VIL (max): 0.3 × VDDIO
    *   VIH (min): 0.7 × VDDIO
    *   VOL (max): 0.4V @ IOL=8mA
    *   VOH (min): VDDIO - 0.4V @ IOH=-8mA
    *   Drive Strength: Configurable (e.g., 2/4/8 mA)
    *   Maximum Toggle Rate: 20 MHz

#### 4.3. Protocol-Specific Interfaces

*   **UART:**
    *   Baud Rates: 300 bps to 4 Mbps
    *   Data Bits: 7, 8, 9
    *   Parity: None, Even, Odd
*   **SPI:**
    *   Clock Speed: Up to 20 MHz
    *   Modes: CPOL/CPHA 0, 1, 2, 3
    *   Data Width: 8/16/32-bit frames
*   **I2C:**
    *   Speed Modes: 100kHz (Standard), 400kHz (Fast), 1MHz (Fast+)
    *   Addressing: 7-bit and 10-bit supported
    *   Features: Clock stretching, multi-master support.

---

### 5. Key Design Constraints and Assumptions

1.  **CPU Core & Interrupts:** The core is the `hazard3_2port_swd` RISC-V (RV32I) implementation. The integrated Platform-Level Interrupt Controller (PLIC) is the sole interrupt manager for the 26 specified peripheral IRQs mapped in Section 3.
2.  **Memory Implementation:**
    *   SRAM shall be implemented using four `CF_SRAM_1024x32` (32 KB) compiler macros.
    *   Flash is off-chip. The `nc_xip` controller provides a 512 KB, cacheable, read-only/execute-only window starting at `0x0000_0000`.
3.  **Peripheral IP:** All enumerated peripheral IP blocks (`nc_*`) are assumed to be pre-verified. This specification governs their SoC-level integration (addressing, interrupts, clock/reset).
4.  **Analog Integration:** The 12-bit SAR ADC is a mixed-signal macro. This specification defines only its digital APB control interface. The digital logic, alternate functions, and IRQ for the second ADC (ADC1) are to be removed entirely.
5.  **Pin-out & Software Compatibility:**
    *   The package and pinout must remain 100% compatible with the reference device.
    *   The new I2C2 peripheral must utilize existing GPIO pins on **Port B** via the alternate function matrix in SYS_CTRL.
    *   Software is register-level compatible except for:
        *   Memory map adjusted for 512KB Flash / 128KB SRAM.
        *   Reads from any address corresponding to the removed ADC1 shall return `0x0000_0000`.
        *   I2C2 registers at `0x4000_C000` are now functional.
6.  **Power & Clocking:**
    *   **Supplies:** Core Logic: 1.8V (VCCD); I/O Pads: 3.3V (VDDIO); Analog Blocks: 3.3V (VDDA). Appropriate level shifting is required at all voltage domain crossings.
    *   **Clocking:** A single root clock source (CLK_IN) generates the main system clock (`HCLK`). The APB clock (`PCLK`) is derived from `HCLK` (configurable, e.g., HCLK/2, HCLK/4).
7.  **Reset Scheme:** A single active-low global reset signal (`nRESET`) is distributed to synchronously reset the entire digital subsystem. All registers must adhere to a `0x0000_0000` value on reset unless otherwise specified.
8.  **Technology Assumptions:** The design targets a 40nm CMOS process. Standard cell libraries and memory compilers for this node will be used. Corner analysis shall cover SS/TT/FF process models from -40°C to +125°C.

---

*End of raw advisory output.*
