# User Brief: Derivative MCU from TI MSPM33C321A

## Reference Device
- **Part Number:** MSPM33C321A
- **Manufacturer:** Texas Instruments
- **Product URL:** https://www.ti.com/product/MSPM33C321A
- **Core:** Arm® Cortex®-M0+ @ up to 80 MHz
- **Flash (Reference):** 1MB
- **SRAM (Reference):** 64KB (MSPM33C321A baseline — derivative targets 128KB via upgrade)
- **Package:** Multiple options (LQFP, VQFN, etc.)

## Derivative Changes (Delta from Reference)

| Parameter        | Reference (MSPM33C321A) | Derivative Target |
|------------------|------------------------|-------------------|
| Flash            | 1 MB                   | **512 KB**        |
| SRAM             | varies                 | **128 KB**        |
| ADC instances    | 2 (12-bit SAR ADCs)    | **1 (remove 1)**  |
| I2C instances    | existing               | **+1 additional** |

## Scope Statement
The scope of the change is intentionally small — this is a derivative/cost-reduced variant of the MSPM33C321A. All other peripherals, clocking, pinout strategy, and subsystem architecture remain consistent with the reference device unless directly impacted by the delta changes above.

## Requested Artifacts (Illustrative, Not Exhaustive)
- New device specification document
- Memory map (updated for 512KB flash, 128KB SRAM)
- Interrupt map (updated for ADC removal and I2C addition)
- Integration document
- Verification plan
- Test benches (representative samples)
- IO ring / padframe requirements
- Floorplan guidance
- DFT (Design-for-Test) change notes

## Design Name
`mspm33c321a_derivative` (working name: `mspm33c321a_deriv`)

## Project Root
`/workspace/nc-project-20260529-210526`

## Date
2026-05-29
