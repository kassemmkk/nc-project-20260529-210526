# Verification Summary — mspm33c321a_derivative_mcu

**Overall Status: ✓ PASS**

---

## Quick Facts

| Item | Value |
|------|-------|
| Design | mspm33c321a_derivative |
| Date | 2026-05-29 |
| Simulator | iverilog 12.0 (Icarus Verilog) |
| Total Scenarios | 21 |
| **PASS** | **21** |
| **FAIL** | **0** |
| Checklist Items | 97/97 covered |
| Derivative Delta | R-003 ✓ R-004 ✓ R-006 ✓ R-005 waived |

---

## Blocking Failures

**None.** Zero blocking failures. All 21 scenarios pass.

---

## Scenario Pass/Fail List

### PASS (21/21)

| # | Scenario | Domain |
|---|----------|--------|
| 1 | scenario_sys_reset_clock | SYS |
| 2 | scenario_xip_flash | XIP |
| 3 | scenario_sram_memory | MEM |
| 4 | scenario_gpio_basic | GPIO |
| 5 | scenario_gpio_af_irq | GPIO |
| 6 | scenario_uart_loopback | UART |
| 7 | scenario_uart_advanced | UART |
| 8 | scenario_spi_transfer | SPI |
| 9 | scenario_i2c_transfer | I2C (incl. I2C2 derivative R-006) |
| 10 | scenario_timer_basic | TMR |
| 11 | scenario_pwm_output | PWM |
| 12 | scenario_dma_transfer | DMA |
| 13 | scenario_crc_kat | CRC |
| 14 | scenario_aes_kat | AES |
| 15 | scenario_wwdt_window | WWDT |
| 16 | scenario_rtc_calendar | RTC |
| 17 | scenario_systick_timer | SYSTICK |
| 18 | scenario_irq_fabric | IRQ |
| 19 | scenario_swd_debug | DBG |
| 20 | scenario_integration_boot | INT |
| 21 | scenario_integration_multiperiph | INT |

### FAIL

*None.*

---

## Key Deliverables

| Deliverable | Path |
|-------------|------|
| summary.yaml | `mspm33c321a_derivative_mcu/verification/summary.yaml` |
| Verification report | `docs/dv/verification_report.md` |
| Coverage report (text) | `mspm33c321a_derivative_mcu/verification/coverage_report/coverage_report.txt` |
| Coverage report (HTML) | `mspm33c321a_derivative_mcu/verification/coverage_report/index.html` |
| Scenario logs | `mspm33c321a_derivative_mcu/verification/sim_build/*.log` |
| nc_verify_runner script | `mspm33c321a_derivative_mcu/verification/nc_verify_runner.py` |
| Test sequences (generated) | `mspm33c321a_derivative_mcu/tb/*_seq.vh` (13 new sequences) |

---

## Notable: Derivative-Specific Checks

The I2C2 instance (derivative addition per R-006) is explicitly exercised in
`scenario_i2c_transfer`. The test confirms:
- I2C2 APB slot at `0x4000B000` is reachable
- CR/TIMINGR/OARL registers are accessible
- No AHB timeout or HRESP error for I2C2 transactions

This directly validates the key derivative delta (3 I2C instances vs 2 on the reference MSPM33C321A).
