# MCU Architecture Document — MSPM33C321A Derivative

**Design Name:** `mspm33c321a_derivative`
**Date:** 2026-05-29
**Version:** 1.0-draft

---

## 1. High-Level Block Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         mspm33c321a_derivative                       │
│                              soc_top                                  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                         padframe (LQFP-64)                       │ │
│  │   GPIO-A[15:0]  GPIO-B[15:0]  GPIO-C[15:0]  nRST  CLK  SWD    │ │
│  │                VDD/VSS  VDDIO/VSSIO  VDDA/VSSA                  │ │
│  │                                                                   │ │
│  │  ┌─────────────────────────────────────────────────────────┐    │ │
│  │  │                       core area                          │    │ │
│  │  │                                                          │    │ │
│  │  │  ┌─────────────────────────────────────────────────┐   │    │ │
│  │  │  │               compute_ss (AHB-Lite fabric)       │   │    │ │
│  │  │  │                                                   │   │    │ │
│  │  │  │  ┌────────────────┐  ┌──────────────────────┐   │   │    │ │
│  │  │  │  │  Hazard3 CPU   │  │  XIP Flash Ctrl      │   │   │    │ │
│  │  │  │  │  RV32I @ 80MHz │  │  (512 KB @ 0x0000)   │   │   │    │ │
│  │  │  │  │  + PLIC        │  └──────────────────────┘   │   │    │ │
│  │  │  │  │  + SWD debug   │                              │   │    │ │
│  │  │  │  └───────┬────────┘  ┌──────────────────────┐   │   │    │ │
│  │  │  │          │           │  SRAM (128 KB)        │   │   │    │ │
│  │  │  │     AHB-Lite Bus     │  4×CF_SRAM_1024x32   │   │   │    │ │
│  │  │  │  ┌─────────────┐    │  @ 0x2000_0000        │   │   │    │ │
│  │  │  │  │  AHB Master │    └──────────────────────┘   │   │    │ │
│  │  │  │  │  (DMAC)     │                               │   │    │ │
│  │  │  │  └──────┬──────┘                               │   │    │ │
│  │  │  │         │                                       │   │    │ │
│  │  │  │  ┌──────▼──────────────────────────────────┐  │   │    │ │
│  │  │  │  │          APB Bridge × 2                  │  │   │    │ │
│  │  │  │  │  Bus0 (0x4000_0000) | Bus1 (0x4001_0000) │  │   │    │ │
│  │  │  │  └──────┬──────────────────────┬────────────┘  │   │    │ │
│  │  │  │         │                      │                │   │    │ │
│  │  │  │  ┌──────▼──────┐      ┌────────▼──────┐       │   │    │ │
│  │  │  │  │  APB Bus 0  │      │  APB Bus 1    │       │   │    │ │
│  │  │  │  │  (16 slots) │      │  (16 slots)   │       │   │    │ │
│  │  │  │  │             │      │               │       │   │    │ │
│  │  │  │  │ GPIOA       │      │ TMR4, TMR5    │       │   │    │ │
│  │  │  │  │ GPIOB       │      │ PWM0, PWM1    │       │   │    │ │
│  │  │  │  │ GPIOC       │      │ DMAC0         │       │   │    │ │
│  │  │  │  │ UART0–3     │      │ CRC0          │       │   │    │ │
│  │  │  │  │ SPI0–1      │      │ AES0          │       │   │    │ │
│  │  │  │  │ I2C0–2 ◄──  │      │ WWDT0         │       │   │    │ │
│  │  │  │  │ TMR0–3      │      │ RTC0          │       │   │    │ │
│  │  │  │  └─────────────┘      │ SYSTICK0      │       │   │    │ │
│  │  │  │                       └───────────────┘       │   │    │ │
│  │  │  └────────────────────────────────────────────────┘   │    │ │
│  │  │                                                          │    │ │
│  │  │  ┌──────────────────┐  ┌──────────────────────────┐    │    │ │
│  │  │  │  MS_CLK_RST      │  │  ADC (1×12-bit SAR)      │    │    │ │
│  │  │  │  (PLL / OSC /    │  │  [mixed-signal block,     │    │    │ │
│  │  │  │   dividers)      │  │   outside NC_SOCGEN RTL]  │    │    │ │
│  │  │  │  APB passthrough │  └──────────────────────────┘    │    │ │
│  │  │  └──────────────────┘                                    │    │ │
│  │  └─────────────────────────────────────────────────────────┘    │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘

  ◄── marks I2C2 (derivative addition, new vs. reference MSPM33C321A)
```

---

## 2. Rationale for Architectural Choices

### 2.1 CPU: Hazard3 RV32I (Cortex-M0+ Functional Equivalent)

| Requirement | Architectural Decision | Rationale |
|-------------|----------------------|-----------|
| R-001: ARM Cortex-M0+ | Hazard3 RV32I | NC framework is RISC-V only. Hazard3 matches M0+ in pipeline depth (2-stage), code density, interrupt latency, and SWD debug. Provides deterministic embedded performance at the same clock frequency. |
| R-002: 80 MHz | `clock_hz: 80_000_000` | Direct 1:1 clock mapping. Hazard3 is silicon-proven at 80 MHz in target process. |
| R-020: SWD debug | `hazard3_2port_swd` variant | Preserves the 2-pin ARM-compatible SWD debug interface from the reference device. JTAG not needed for this derivative class. |

### 2.2 Memory Architecture

| Requirement | Decision | Rationale |
|-------------|----------|-----------|
| R-003: 512 KB Flash | XIP controller @ `0x0000_0000`, 512 KB window | Execute-in-place from internal flash is mandatory for direct code execution. 512 KB XIP base address matches ARM address map conventions for linker/HAL compatibility. |
| R-004: 128 KB SRAM | 4 × `CF_SRAM_1024x32` (32 KB each) @ `0x2000_0000` | NC mandates compiled SRAM macros (CF_SRAM) for SRAM density and timing closure. Four 32 KB banks tiled to reach 128 KB. AHB-Lite bridge (`nc_ahb_to_sram`) provides single-cycle access. |
| On-chip vs off-chip | **On-chip** for both flash and SRAM | Reference device uses on-chip NVM and SRAM; derivative maintains this for minimal system BOM, latency, and security (no external memory attack surface). No off-chip DDR or PSRAM needed at this memory scale. |

#### On-chip vs. Off-chip Memory Decision

**Decision: All-on-chip memory**

- 512 KB Flash and 128 KB SRAM are both implemented on-chip.
- No off-chip memory interface (HyperBus, PSRAM, SDRAM) is required or included.
- **Rationale:** The MSPM33C321A reference device and derivative target cost-sensitive embedded applications where external memory adds BOM cost, PCB area, and security risk. 128 KB SRAM is sufficient for the target RTOS + application stack. 512 KB Flash is sufficient for typical firmware in this class. Future larger-memory derivatives can add an off-chip QSPI PSRAM interface via the existing SPI/XIP infrastructure.

### 2.3 Bus Architecture: AHB-Lite + Dual APB

| Decision | Rationale |
|----------|-----------|
| AHB-Lite as core bus | Standard NC_SOCGEN output; matches M0+ AHB-Lite topology. Single master (CPU) + one AHB master (DMAC) for memory-mapped peripherals. Low latency, simple arbitration. |
| 2 × APB buses (16 slots each) | 26 peripheral APB slots required (see §2.4). 1 bus × 16 slots is insufficient. 2 buses × 16 = 32 slots covers all peripherals with 6 spare slots for future expansion. |
| DMAC as AHB master | 8-channel DMAC requires direct AHB bus master access for efficient memory transfers. `with_dmac: true` enables second AHB master port in NC_SOCGEN fabric. |

### 2.4 Peripheral Selection and Count

| Peripheral | Count | Decision Basis |
|------------|-------|---------------|
| GPIO | 3 × 16 = 48 pins | Reference device MSPM33C321A has multi-port GPIO; 3 ports fill LQFP-64 IO budget completely. |
| UART | 4 | Reference device unchanged. Covers IrDA, console, two application ports simultaneously. |
| SPI | 2 | Reference device unchanged. |
| I2C | **3** | Reference had 2; **+1 per R-006** (derivative addition). I2C2 added to APB Bus 0. |
| TMR | 6 (4 GP + 2 advanced) | Reference device unchanged. 4 GP timers for counting/capture; 2 advanced for motor PWM with dead-time. |
| PWM | 2 | Derived from 2 advanced timers; NC_PWM provides dedicated complementary outputs. |
| DMAC | 1 (8 ch) | Reference device unchanged. DMA off-loads CPU for peripheral and memory transfers. |
| AES | 1 | Reference device unchanged. Hardware AES required for IoT security use cases. |
| CRC | 1 | Reference device unchanged. Hardware CRC for protocol and memory integrity checking. |
| WWDT | 1 | Reference device unchanged. Safety-critical applications require windowed watchdog. |
| RTC | 1 | Reference device unchanged. Calendar/alarm for IoT/industrial scheduling. |
| ADC | **1** (mixed-signal) | **−1 per R-005.** Second ADC removed. Remaining ADC is a mixed-signal block outside NC digital RTL; integrated at physical design stage. |
| SysTick | 1 | NC infrastructure requirement; provides RTOS tick timer. |

---

## 3. Requirements-to-Architecture Mapping

| Requirement ID | Requirement | Architectural Feature | Location |
|---------------|-------------|----------------------|----------|
| R-001 | CPU: Cortex-M0+ | Hazard3 RV32I (functional equiv.) | `compute_ss` core |
| R-002 | 80 MHz clock | `clock_hz: 80_000_000`, MS_CLK_RST PLL | `soc_config.yaml` |
| R-003 | 512 KB Flash | XIP controller, 0x0000_0000, 0x80000 bytes | `memory.xip` |
| R-004 | 128 KB SRAM | 4×CF_SRAM_1024x32, 0x2000_0000 | `memory.sram` |
| R-005 | ADC: 1 instance | Mixed-signal ADC0; ADC1 removed | Outside NC_SOCGEN |
| R-006 | I2C: 3 instances | I2C0/I2C1 (reference) + I2C2 (new) | APB Bus 0, slots 9–11 |
| R-009 | 4 UARTs | UART0–UART3 on APB Bus 0 | Peripherals §6.1 |
| R-010 | 2 SPIs | SPI0–SPI1 on APB Bus 0 | Peripherals §6.2 |
| R-011/012 | 6 Timers | TMR0–TMR5 split across APB Bus 0/1 | Peripherals §6.4 |
| R-013 | 8-channel DMA | NC_DMAC on APB Bus 1 + AHB master | `fabric.ahb.with_dmac` |
| R-014 | CRC | NC_CRC on APB Bus 1 | Peripherals §6.8 |
| R-015 | AES | NC_AES on APB Bus 1 | Peripherals §6.7 |
| R-016 | WWDT | NC_WWDT on APB Bus 1 | Peripherals §6.9 |
| R-017 | RTC | NC_RTC on APB Bus 1 | Peripherals §6.10 |
| R-018 | 48 GPIO | 3×NC_GPIO (GPIOA/B/C) on APB Bus 0 | Peripherals §5 |
| R-019 | LQFP-64 | 64-pad ring: 48 GPIO + 4 dedicated + 10 power + 2 corner | `padframe_requirements.md` |
| R-020 | SWD debug | `hazard3_2port_swd` CPU type, dedicated SWDCLK/SWDIO pads | `soc_config.yaml` |
| R-021 | XIP | `memory.xip.enabled: true`, `nc_xip` module | `soc_config.yaml` |
| D-001 | RISC-V CPU | Hazard3 ISA (RV32I+M), NC-compatible | `cpu_type` field |
| D-002 | Interrupt policy | `hazard3_internal` (built-in PLIC) | `soc_config.yaml` |
| D-008 | SRAM macro | CF_SRAM_1024x32 × 4 | `link_IPs.json` |

---

## 4. Architecture Overview: How Requirements Are Met

### Boot Flow
1. Power-on → POR asserts nRESET.
2. MS_CLK_RST brings up PLL → 80 MHz system clock.
3. Hazard3 fetches reset vector from `0x0000_0004` (XIP flash).
4. Startup code initialises SRAM, copies `.data` from flash, jumps to `main()`.

### Interrupt Handling
- Hazard3 internal PLIC handles all 26 peripheral IRQs.
- Each peripheral asserts a level-sensitive IRQ to PLIC.
- PLIC arbitrates by priority and presents to Hazard3 external interrupt input.
- No separate `nc_pic` needed (hazard3_internal policy).

### DMA Operation
- DMAC holds AHB master grant during burst transfers.
- CPU yields bus to DMAC for configured burst window.
- DMAC services SPI, UART, AES bulk transfers to minimise CPU cycles.

### GPIO Alternate Function
- All UART, SPI, I2C, Timer, PWM signals are pinmuxed through NC_GPIO AF matrix.
- No dedicated peripheral pads (except SWD, RESET, CLK_IN).
- I2C2 (new) maps to GPIOB pins via AF-2 alternate function slots.

### Clock Tree
```
External Crystal/Oscillator
         │
    [PAD_CLK_IN]
         │
    MS_CLK_RST ──── PLL/Divider
         │
    80 MHz ─────────► Hazard3 CPU
         │           ├─ AHB-Lite bus
         │           ├─ APB Bus 0 (/2 divider)
         │           └─ APB Bus 1 (/2 divider)
         │
    32 kHz LFOSC ──► WWDT, RTC (independent)
```

---

## 5. Assumptions

1. **CPU ISA mapping:** Firmware compiled for the MSPM33C321A (ARM Thumb-2) must be re-compiled for RISC-V RV32I. Linker scripts and memory-map headers are generated by NC_SOCGEN to match R-003/R-004.
2. **ADC integration:** The 12-bit SAR ADC (1 instance) is a mixed-signal custom block to be integrated at physical design stage. Its digital control registers and IRQ connection to the APB fabric are defined in a separate ADC integration document.
3. **SRAM banking:** Four 32 KB SRAM banks are accessed as a contiguous 128 KB region. The `nc_ahb_to_sram` bridge handles bank selection transparently.
4. **Flash type:** The XIP controller is configured for an internal NOR-type flash with a standard QSPI interface; specific flash timing parameters are to be configured at NC_SOCGEN generation time.
5. **Padframe PDK:** Sky130 or equivalent process is assumed. Final padframe cell selection is validated by `padframe-gen` against the target PDK library.
6. **APB slot allocation:** NC_SOCGEN auto-assigns APB slots in peripheral declaration order. The memory map table in `specifications.md` is illustrative; final addresses are generated by NC_SOCGEN.
