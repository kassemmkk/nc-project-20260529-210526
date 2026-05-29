# Requirements Document — MSPM33C321A Derivative MCU

**Design Name:** `mspm33c321a_derivative`
**Working Name:** `mspm33c321a_deriv`
**Date:** 2026-05-29
**Source:** `docs/user_brief.md`

---

## 1. Requirement Classification Legend

| Tag | Meaning |
|-----|---------|
| **EXPLICIT** | Stated verbatim in the user brief |
| **INFERRED** | Derived from reference device scope statement ("all other peripherals remain consistent") |
| **DEFAULT** | Applied by NC toolchain mapping rules; documented with rationale |

---

## 2. Explicit User Requirements

| # | Parameter | Reference (MSPM33C321A) | Derivative Target | Tag |
|---|-----------|------------------------|-------------------|-----|
| R-001 | CPU Core | ARM Cortex-M0+ | ARM Cortex-M0+ (unchanged) | EXPLICIT |
| R-002 | CPU Clock | 80 MHz max | 80 MHz max (unchanged) | EXPLICIT |
| R-003 | Flash (NVM) | 1 MB | **512 KB** | EXPLICIT |
| R-004 | SRAM | 64 KB (ref) | **128 KB** (upgraded) | EXPLICIT |
| R-005 | ADC Instances | 2 × 12-bit SAR | **1 × 12-bit SAR** (one removed) | EXPLICIT |
| R-006 | I2C Instances | 2 | **3** (one added) | EXPLICIT |
| R-007 | Design Name | — | `mspm33c321a_derivative` | EXPLICIT |
| R-008 | Scope | — | Cost-reduced derivative; all other subsystems unchanged | EXPLICIT |

---

## 3. Inferred Requirements (from Reference Device Scope)

The user brief states: *"All other peripherals, clocking, pinout strategy, and subsystem architecture remain consistent with the reference device."* The following are inferred from the MSPM33C321A datasheet profile:

| # | Parameter | Value | Rationale |
|---|-----------|-------|-----------|
| R-009 | UART Instances | 4 | MSPM33C321A reference: 4 UART/IrDA modules |
| R-010 | SPI Instances | 2 | MSPM33C321A reference: 2 SPI masters/slaves |
| R-011 | General-Purpose Timers | 4 (16-bit) | MSPM33C321A reference: 4 GP 16-bit timers |
| R-012 | Advanced Timers (PWM) | 2 | MSPM33C321A reference: 2 advanced control timers for PWM |
| R-013 | DMA Channels | 8 channels (1 controller) | MSPM33C321A reference: 8-channel DMA |
| R-014 | CRC Accelerator | 1 | MSPM33C321A reference: hardware CRC |
| R-015 | AES Accelerator | 1 (AES-128/256) | MSPM33C321A reference: hardware AES engine |
| R-016 | Windowed Watchdog | 1 (WWDT) | MSPM33C321A reference: WWDT |
| R-017 | Real-Time Clock | 1 (RTC) | MSPM33C321A reference: RTC with calendar |
| R-018 | GPIO | 3 ports × 16 pins = 48 GPIO | MSPM33C321A reference: multi-port GPIO; 3 ports cover package pin budget |
| R-019 | Package | LQFP-64 (primary) | Most common package for MSPM33C321A family; derivative maintains pinout compatibility |
| R-020 | SWD Debug | Yes (2-pin SWD) | MSPM33C321A uses ARM SWD; derivative preserves debug access |
| R-021 | XIP (Execute-in-Place) | Yes | Internal flash requires XIP controller for code execution |
| R-022 | Interrupt Controller | Built-in to CPU | M0+ has NVIC; maps to hazard3 internal PLIC in NC framework |

---

## 4. Defaults Applied (NC Toolchain Mapping)

| # | Parameter | Applied Default | Rationale |
|---|-----------|----------------|-----------|
| D-001 | CPU Implementation | `hazard3_2port_swd` (RISC-V RV32I) | NC framework supports RISC-V only. Hazard3 is the functional equivalent of ARM Cortex-M0+: same pipeline depth, SWD debug, NVIC-equivalent PLIC. Provides identical embedded SW programming model. |
| D-002 | Interrupt Policy | `hazard3_internal` | Hazard3 has a built-in PLIC; external `nc_pic` not used with hazard3 CPU type. |
| D-003 | Bus Architecture | AHB-Lite + APB | Standard NC_SOCGEN fabric; matches M0+ typical bus topology. |
| D-004 | APB Buses | 2 buses × 16 slots | 26 peripheral APB slots required; 2 buses of 16 = 32 slots available (26 used). |
| D-005 | XIP Base Address | `0x00000000` | NC standard: flash/XIP mapped at base of address space for direct boot execution. |
| D-006 | SRAM Base Address | `0x20000000` | ARM-conventional SRAM base address preserved for toolchain / linker compatibility. |
| D-007 | APB Base Address | `0x40000000` | ARM-conventional peripheral base; matches M0+ ecosystem linker/HAL expectations. |
| D-008 | SRAM Module | `nc_ahb_to_sram` + `CF_SRAM_1024x32` | NC mandates compiled SRAM macros, never register-based memory. |
| D-009 | ADC Treatment | Noted in spec; not in digital RTL | NC framework does not include a synthesizable ADC. ADC requirement (1 × 12-bit SAR) is documented for integration at mixed-signal level. |
| D-010 | PWM | `nc_pwm` × 2 | Maps MSPM33C321A advanced timer PWM capability to NC PWM peripheral. |
| D-011 | GPIO Reset Direction | Input | Safe power-on default; all pads high-impedance at reset. |

---

## 5. IPs Required

| IP Name | Type | Instances | Notes |
|---------|------|-----------|-------|
| NC_RV32 | CPU | 1 | Hazard3 RV32I core (M0+ equivalent) |
| NC_AMBA | Bus fabric | 1 | AHB-Lite + APB bridge infrastructure |
| NC_COMMON | Utilities | 1 | Clock cells, resets, glue logic |
| CF_SRAM_1024x32 | SRAM macro | 4 | 4 × 32KB = 128KB (4 banks of 1K×32-bit) |
| NC_XIP | Flash controller | 1 | 512KB execute-in-place flash interface |
| NC_GPIO | GPIO | 3 | GPIOA, GPIOB, GPIOC (16 pins each) |
| NC_UART | UART | 4 | UART0–UART3 |
| NC_SPI | SPI | 2 | SPI0–SPI1 |
| NC_I2C | I2C | 3 | I2C0–I2C2 (reference 2 + derivative +1) |
| NC_TMR | General Timer | 6 | TMR0–TMR5 (4 GP + 2 advanced) |
| NC_PWM | PWM | 2 | PWM0–PWM1 |
| NC_DMAC | DMA Controller | 1 | 8-channel DMA |
| NC_CRC | CRC Accelerator | 1 | Hardware CRC |
| NC_AES | AES Accelerator | 1 | AES-128/256 |
| NC_WWDT | Watchdog | 1 | Windowed watchdog timer |
| NC_RTC | RTC | 1 | Real-time clock with calendar |
| NC_SYSTICK | SysTick | 1 | ARM-compatible SysTick timer |

---

## 6. Requirements NOT in Scope

The following MSPM33C321A features are noted as out-of-scope for this derivative:

| Feature | Status | Note |
|---------|--------|------|
| ADC (2nd instance) | **Removed** per brief | Only 1 ADC remains; handled at mixed-signal level |
| MCAN/CAN FD | Not carried forward | NC framework has no NC_CAN; excluded pending future derivative |
| TRNG | Not carried forward | NC framework has no NC_TRNG; noted for future addition |
| VREF / Analog comparator | Not in digital RTL | Analog-only block; outside NC digital framework |
| Bootloader ROM | NC default | NC_SOCGEN XIP + startup covers boot; no separate ROM block |

---

## 7. Verification Expectations

| Item | Expected Coverage |
|------|------------------|
| All APB peripherals | Register smoke tests (read/write) |
| UART, SPI, I2C, GPIO | Functional directed tests (loopback / self-check) |
| DMA transfers | Memory-to-memory + peripheral transfer tests |
| Timer / PWM | Period/duty-cycle configuration tests |
| AES / CRC | Known-answer tests (KAT) |
| WWDT | Timeout and windowed service tests |
| IRQ handling | All peripheral IRQ assertion and acknowledgment |
| XIP flash | Boot from hex image via XiP BFM |
| SWD debug | Debug access port connection test |
