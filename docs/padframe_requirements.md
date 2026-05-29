# Padframe Requirements — MSPM33C321A Derivative MCU

**Design Name:** `mspm33c321a_derivative`
**Date:** 2026-05-29
**Source:** `docs/requirements.md`, `docs/specifications.md`

---

## 1. Overview

This document defines the IO ring (padframe) requirements for the `mspm33c321a_derivative`. The padframe must accommodate 48 GPIO signal pads (3 × 16-pin GPIO ports), 4 dedicated function pads, and 8 power pads, totalling 60 functional pads within the LQFP-64 package body. The remaining 4 pad positions are allocated to corner/filler pads.

---

## 2. GPIO Count and Grouping

### 2.1 GPIO Pad Count

| Port | Pins | Description |
|------|------|-------------|
| GPIOA | 16 | Port A (PA[15:0]) — NC_GPIO instance 0 |
| GPIOB | 16 | Port B (PB[15:0]) — NC_GPIO instance 1 |
| GPIOC | 16 | Port C (PC[15:0]) — NC_GPIO instance 2 |
| **Total GPIO** | **48** | All bidirectional, configurable drive strength |

### 2.2 Grouping Assumptions

- Each 16-pin GPIO port maps to one `nc_gpio` peripheral instance.
- All GPIO pads are bidirectional (general-purpose IO) with full alternate function support.
- Pads support push-pull output, open-drain output, and input-only modes.
- Ports are distributed around the padframe to minimise signal routing distance to their primary peripheral assignment:
  - **GPIOA** — North/East sides: UART0/1, SPI0, I2C0/1 area
  - **GPIOB** — East/South sides: UART2/3, SPI1, I2C2 area
  - **GPIOC** — South/West sides: TMR4/5, PWM0/1, misc area
- Pad ordering within each port follows ascending pin number (P_0 at the lower-index pad position).

### 2.3 Alternate Function Pinmux (per pad)

Each GPIO pad in the padframe exposes:
- `core_gpio_N_out` — output data from nc_gpio AF matrix
- `core_gpio_N_oe_n` — output enable (active-LOW to padframe)
- `core_gpio_N_in` — sampled input data to nc_gpio
- `core_gpio_N_dm_[2:0]` — drive-mode select (strong/weak/open-drain)
- `core_gpio_N_inp_dis` — input path disable (for pure output / analog mode)
- `core_gpio_N_enable_h` — pad enable (active-HIGH)
- `core_gpio_N_slow` — slew-rate limiter enable

---

## 3. Dedicated Function Pads

| Pad Name | Direction | Function | Notes |
|----------|-----------|----------|-------|
| `PAD_NRESET` | Input | External reset, active-low | Schmitt trigger; glitch-filtered; connects to reset synchronizer |
| `PAD_CLK_IN` | Input | External clock/crystal input | Low-jitter clock pad; typically connected to crystal oscillator |
| `PAD_SWDCLK` | Input | SWD clock (SWD debug) | Dedicated Hazard3 SWD interface; no GPIO function |
| `PAD_SWDIO` | Bidirectional | SWD data (SWD debug) | Dedicated Hazard3 SWD interface; no GPIO function |

---

## 4. Power Pads

### 4.1 Required Power Pads

| Pad Name | Count | Rail | Nominal Voltage | Scope |
|----------|-------|------|----------------|-------|
| `VDD` | 2 | VCCD | 1.8 V | CPU core, SRAM, bus logic |
| `VSS` | 2 | VSSD | 0 V | Core ground |
| `VDDIO` | 2 | VDDIO | 3.3 V | GPIO IO ring drivers |
| `VSSIO` | 2 | VSSIO | 0 V | IO ground return |
| `VDDA` | 1 | VDDA | 3.3 V | ADC, VREF, analog subsystem |
| `VSSA` | 1 | VSSA | 0 V | Analog ground (isolated from VSSIO) |
| **Total** | **10** | | | |

> **Rationale:** Dual VDD/VSS pads reduce IR-drop across the core power mesh at 80 MHz operation. Dual VDDIO/VSSIO pads split IO ring power delivery symmetrically around the die perimeter. VDDA/VSSA are isolated from digital power for ADC noise performance. Total power pad count: 10.

### 4.2 Power Pad Distribution Strategy

```
             [North side]
   VDD  VDDIO  GPIO_A[15:8]  ...  GPIO_A[7:0]  SWDCLK
   |                                               |
[W]                                              [E]
   |                                               |
   VSS  VSSIO  GPIO_B[15:8]  ...  GPIO_B[7:0]  SWDIO
             [South side]
   VDDA  VSSA  GPIO_C[15:8]  ...  GPIO_C[7:0]  PAD_NRESET
   VDD   VDDIO  ...                            CLK_IN
   VSS   VSSIO
```

> Power pads are distributed roughly symmetrically: one VDD/VSS pair on the North side, one pair on the South side; one VDDIO/VSSIO pair on the North side, one pair on the South side; VDDA/VSSA on one corner group.

---

## 5. Package-Fit Assumptions and Constraints

### 5.1 Primary Package: LQFP-64

| Parameter | Value | Constraint |
|-----------|-------|-----------|
| Total package pins | 64 | Fixed — 64-lead LQFP |
| IO signal pads (GPIO) | 48 | 3 ports × 16 pins |
| Dedicated signal pads | 4 | nRESET, CLK_IN, SWDCLK, SWDIO |
| Power pads | 10 | 2×VDD/VSS + 2×VDDIO/VSSIO + VDDA/VSSA |
| Corner / filler pads | 2 | LQFP corner cells for structural ring closure |
| **Total occupied** | **64** | Fits exactly in LQFP-64 |

> **Constraint:** The total number of padframe cells (signal + power + corner) must not exceed 64. With 48 GPIO + 4 dedicated + 10 power + 2 corner = 64. ✓

### 5.2 Alternate Package: VQFN-64

Same pin count and signal assignment; the thermal pad (exposed die-attach pad) is tied to VSS and acts as an additional ground connection but does not occupy a padframe cell position.

### 5.3 Pad Technology Assumptions

- All digital IO pads: sky130 / target PDK general-purpose IO cell (bidirectional, 3.3 V tolerant, configurable drive strength: 2 mA / 4 mA / 8 mA / 12 mA).
- Power pads: PDK power-clamp cells with ESD protection.
- Clock input pad: specialised low-jitter analog-input cell to minimise clock skew and reduce phase noise injection.
- Reset pad: Schmitt-trigger input with internal pull-up (10 kΩ typical).
- SWD pads: weak pull-up on SWDIO, no pull on SWDCLK (driven by external debug probe).

### 5.4 Padframe Ring Closure

- 4 corner pad cells required for physical LQFP ring integrity.
- Filler / breaker cells may be inserted as required by `padframe-gen` to achieve DRC-clean ring.
- Bond wire to pad pitch: 0.5 mm (LQFP-64 standard).

---

## 6. ESD and Latch-up Requirements

| Parameter | Requirement |
|-----------|------------|
| HBM ESD | ≥ 2 kV (all IO pads) |
| CDM ESD | ≥ 250 V (all IO pads) |
| Latch-up immunity | > 100 mA trigger current at +85 °C |
| Power clamp | Required on all supply domains (VDD, VDDIO, VDDA) |
| IO clamp diodes | Rail-to-rail protection diodes on all signal pads |

---

## 7. Derivative Impact on Padframe

The padframe changes relative to the reference MSPM33C321A are minimal, consistent with the "small delta" scope:

| Change | Reference | Derivative | Padframe Impact |
|--------|-----------|------------|----------------|
| ADC1 removed | 2 analog mux inputs | 1 analog mux input | ADC1 analog pad group not needed; those GPIO pads become standard digital IO |
| I2C2 added | 2 I2C pinmux channels | 3 I2C pinmux channels | No new pads — I2C2 is assigned to existing GPIOB alternate functions; zero additional pad count |
| Flash 512 KB | 1 MB address | 512 KB address | No padframe impact (internal bus only) |
| SRAM 128 KB | 64 KB | 128 KB | No padframe impact (internal bus only) |

**Net padframe delta:** Zero additional pads required. I2C2 is absorbed into existing GPIOB alternate-function matrix. ADC1 removal frees no pads (GPIO pads remain; their analog-enable signal is de-asserted).

---

## 8. Padframe Configuration Summary (for `padframe-gen`)

```yaml
# Padframe summary — will be formalised in padframe_config.yaml at Stage 3
padframe:
  die_package: LQFP64
  total_pads: 64
  io_signal_pads: 52      # 48 GPIO + 4 dedicated
  power_pads: 10          # VDD×2 + VSS×2 + VDDIO×2 + VSSIO×2 + VDDA + VSSA
  corner_pads: 2

  gpio_ports:
    - name: gpioa
      width: 16
      side: north_east
      reset_oe: input
    - name: gpiob
      width: 16
      side: east_south
      reset_oe: input
    - name: gpioc
      width: 16
      side: south_west
      reset_oe: input

  dedicated_pads:
    - name: nreset
      type: schmitt_input
      pullup: 10k
    - name: clk_in
      type: analog_input
      pullup: none
    - name: swdclk
      type: digital_input
      pullup: none
    - name: swdio
      type: bidirectional
      pullup: weak

  power_pads:
    - name: VDD
      count: 2
      rail: vccd
      voltage: 1.8V
    - name: VSS
      count: 2
      rail: vssd
      voltage: 0V
    - name: VDDIO
      count: 2
      rail: vddio
      voltage: 3.3V
    - name: VSSIO
      count: 2
      rail: vssio
      voltage: 0V
    - name: VDDA
      count: 1
      rail: vdda
      voltage: 3.3V
    - name: VSSA
      count: 1
      rail: vssa
      voltage: 0V
```
